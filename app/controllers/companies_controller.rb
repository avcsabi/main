class CompaniesController < ApplicationController

  def index
    @companies = Company.all.order(:company_name).preload(:address).paginate(page: params[:page], per_page: 100).to_a
  end

  # Search companies using Companies House UK service
  def search_in_companies_house
    if params.has_key?(:term)
      term = params[:term]
      if term.blank?
        flash.now[:error] = 'Please enter a valid search term'
      else
        results = CompaniesHouse.search_company(term)
        if results[:error]
          flash.now[:error] = "Error while searching (#{results[:error]})."
        else
          @results = results
        end
      end
    end
  end

  def destroy
    c = Company.find_by(id: params[:id])
    if c&.destroy
      flash[:notice] = 'Deleted'
    else
      flash[:error] = 'Could not delete company'
    end
    redirect_to action: :index
  end

  def create
    company = Company.new(company_params)
    if company.save
      flash[:notice] = 'Saved'
    else
      flash[:error] = "Could not save company (#{company.errors.full_messages.join('; ')})"
    end
    redirect_to action: :index
  end

  def update
    company = Company.find_by(id: params[:id])
    if company
      updated_company_data = CompaniesHouse.get_company_by_number(company.company_number)
      if updated_company_data[:error]
        flash[:error] = "Error getting company information (#{updated_company_data[:error]})"
      else
        attrs = updated_company_data[:company].attributes.select{|_,v| v.present?}
        attrs[:address_attributes] = updated_company_data[:company].address.attributes.select{|_,v| v.present?}
        if company.update(attrs)
          flash[:notice] = "Data for company with number #{company.company_number} updated"
        else
          flash[:error] = "Error updating company information (#{company.errors.full_messages.join('; ')})"
        end
      end
    else
      flash[:error] = "Could not find company with id #{params[:id]}"
    end
    redirect_to action: :index
  end

  private

  def company_params
    params.require(:company).permit(:company_number, :company_name, :date_of_creation, :type, :jurisdiction, :company_status, address_attributes: [:address_line_1, :address_line_2, :locality, :country, :postal_code])
  end

end
