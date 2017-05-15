class RegistrationController < ApplicationController
  before_filter :check_camper_exists, only: [:create]
  before_filter :check_registration_over, only: [:show, :new, :edit]
  
  def index

  end

  def show   
    unless signed_in?
      redirect_to root_url  
    end
  end

  def new        
    unless @form_object.nil?
      @camper_form_object = @form_object
    else
      @camper_form_object = CamperFormObject.new({email: "", phone_number: ""})
    end
    @action = 'create' 
    @method = :post
    setup_view
  end

  def check_camper_exists
    @form_object = CamperFormObject.new(camper_params.to_hash)
    @new_camper = CamperFormObject.to_camper(@form_object)
    status = camper_exists(@new_camper)
    if status[0] == true
      flash.now[:danger] = status[1]
      setup_view
      @camper_form_object = @form_object      
      render 'new'      
    end
  end

  def create
    if @new_camper.save
      sign_in @new_camper
      flash[:success] = "Registration successful. Please remember to log out when done"
      redirect_to camper_url and return
    else
      setup_view
      @errors = @new_camper.errors
      render 'new'
    end
  end

  def edit    
    camper = Camper.find(params[:id])
    @camper_form_object = CamperFormObject.from_camper(camper)
    @action = 'update' 
    @method = :put
    setup_view    
  end

  def update
    @form_object = CamperFormObject.new(camper_params.to_hash)
    @camper = CamperFormObject.to_camper(@form_object)
    status = camper_exists(@camper)
    
    old_camper = Camper.find(current_user.id)
    attributes = @camper.attributes.with_indifferent_access.deep_symbolize_keys    
    attributes.delete(:_id)
      
    if old_camper.update_attributes(attributes)
      flash[:success] = "Registration details updated. Please remember to log out when done"
      redirect_to camper_url and return
    else
      setup_view
      @errors = @camper.errors
      render 'edit'
    end
  end

  def setup_view   
    @countries = Country::LIST.collect {|p| [ p[:printable_name], p[:name] ] }
    @schools = School::LIST.collect {|p| [ p[:name], p[:name] ] }
    @professions = Lookup::PROFESSIONS.collect {|p| [ p[:name], p[:name] ] }
    @locations = Lookup::SCHOOL_LOCATIONS.collect {|p| [ p[:name], p[:name] ] }
    @educational_levels = Lookup::EDUCATIONAL_LEVELS.collect {|p| [ p[:name], p[:name] ] }
    @roles = Lookup::ROLES.collect {|p| [ p[:name], p[:name] ] }
    @arrival_days = Lookup::ARRIVAL_DAYS.collect {|p| [ p[:name], p[:name] ] }
    @arrival_times = Lookup::ARRIVAL_TIMES.collect {|p| [ p[:name], p[:name] ] }
    @churches = Lookup::CHURCHES.collect {|p| [ p[:name], p[:name] ] }
    if @camper  
      @selected_country = @camper.nationality
    else
      @selected_country = 'GHANA'
    end
  end


  def camper_exists(camper)
    email = camper.email
    phone_number = camper.phone_number
    status = [false, ""]

    if Camper.find_by(email: email, phone_number: phone_number)
      message = 'A camper with the same credential already exists.
      If you are the one kindly login instead'      
      status=[true, message]
    elsif Camper.find_by(email: email)
      message = 'A camper with the same EMAIL already exists.
      If you are the one kindly login instead'
      status=[true, message]
    elsif Camper.find_by(phone_number: phone_number)      
      message = 'A camper with the same PHONE NUMBER already exists.
      If you are the one kindly login instead'
      status=[true, message]
    end
    status
  end

  def check_registration_over
    redirect_to root_url if Settings.registration_ended?
  end

  def camper_params
    params.require(:camper_form_object).permit(:first_name,  :last_name,  :other_names,
    :gender, :date_of_birth,  :email,  :nationality,
    :arrival_day,  :arrival_time,
    :phone_number,  :residence,  :role,
    :emergency_contact, :emergency_number,
    :church, :other_church,
    :occupation,:profession,:other_profession, :school,  :school_location, :educational_level, :other_school,
    :other_school_location,:confirm_email, :confirm_phone_number)
  end

  def print
    render layout: 'print' 
  end
end
