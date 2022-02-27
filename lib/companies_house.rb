class CompaniesHouse
  def self.fetch(api, query, max_retry_count=2)
    last_error = nil
    retry_count = 0
    time_between_attempts = 5
    response = nil
    start_time = Time.now

    config = Rails.application.config.x.companies_house

    uri = URI.parse(config[:service_url]).merge(api)
    COMPANIES_HOUSE_LOGGER.debug("Request: #{uri}\n#{query}")

    client = HTTPClient.new(force_basic_auth: true)
    client.connect_timeout = config[:connect_timeout] || 10
    client.receive_timeout = config[:receive_timeout] || 30
    #config[:service_url]
    client.set_auth uri, config[:api_key], ''
    headers = { 'Accept' => 'application/json' }
    loop do
      begin
        response = client.get(uri, query: query, headers: headers)
      rescue HTTPClient::TimeoutError => e
        COMPANIES_HOUSE_LOGGER.warn("Connection timeout (#{e.class})(attempt #{retry_count + 1})")
        last_error = "No response from Companies House service after #{retry_count + 1} attempts"
      rescue => e
        COMPANIES_HOUSE_LOGGER.error("No response: #{e.message} (#{e.class})(attempt #{retry_count + 1})")
        last_error = "#{e} (attempt #{retry_count + 1})"
      end
      valid_response = response&.content && (response.content&.length || 0) > 0
      break if valid_response
      if retry_count < max_retry_count
        retry_count += 1
      else
        if last_error
          raise last_error
        else
          break
        end
      end
      sleep time_between_attempts
    end
    COMPANIES_HOUSE_LOGGER.debug("Response: #{response&.status} #{response&.reason}\n#{response&.content}")
    {http_response: response, retry_count: retry_count, fetch_duration: Time.now - start_time}
  end

  def self.get_company_by_number(company_number)
    srv_response = fetch("company/#{company_number}", nil)
    srv_response_body = srv_response[:http_response].body
    attrs = JSON.parse(srv_response_body)
    if attrs.present?
      if attrs['errors'].present?
        return {company: nil, error: attrs['errors'][0]['error'].gsub('-', ' ').capitalize}
      end
    end
    company = Company.new
    %i(company_number type jurisdiction company_name company_status date_of_creation).each do |attr|
      val = attrs[attr.to_s].presence
      if val && attr.to_s.starts_with?('date_of_')
        val = Date.parse(val)
      end
      company[attr] = val
    end
    address = Address.new
    addr_attrs = attrs['registered_office_address']
    %i(country locality postal_code address_line_1 address_line_2).each do |attr|
      address[attr] = addr_attrs[attr.to_s]
    end
    company.address = address
    {company: company, error: nil}
  end

  def self.search_company(term, items_per_page=50, start_index=0)
    res = {companies: [], total_results: 0, items_per_page: items_per_page, error: nil}
    srv_response = fetch("search/companies", {q: term, items_per_page: items_per_page, start_index: start_index})
    srv_response_body = srv_response[:http_response].body
    response_h = JSON.parse(srv_response_body)
    if response_h.present?
      if response_h['errors'].present?
        res[:error] = response_h['errors'][0]['error'].gsub('-', ' ').capitalize
        return res
      end
    end
    res[:total_results] = response_h['total_results']
    response_h['items'].each do |attrs|
      company = Company.new
      %i(company_number company_status date_of_creation).each do |attr|
        val = attrs[attr.to_s].presence
        if val && attr.to_s.starts_with?('date_of_')
          val = Date.parse(val)
        end
        company[attr] = val
      end
      company.company_name = attrs['title']
      company.type = attrs['company_type']

      addr_attrs = attrs['address']
      address = Address.new
      if addr_attrs
        %i(country locality postal_code).each do |attr|
          address[attr] = addr_attrs[attr.to_s]
        end
        address.address_line_1 = addr_attrs['premises']
        address.address_line_2 = addr_attrs['address_line_1']
      end
      company.address = address
      res[:companies] << company
    end
    res
  end
end

