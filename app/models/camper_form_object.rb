class CamperFormObject

  attr_accessor :is_admin, :first_name, :last_name, :other_names,
                :gender, :date_of_birth, :email, :confirm_email, :nationality,
                :arrival_day, :arrival_time, :allergy, :departure_day,
                :phone_number, :confirm_phone_number, :residence, :role,
                :emergency_contact, :emergency_number,
                :church, :other_church,
                :occupation, :school, :school_location, :educational_level,
                :other_school, :other_school_location

  TAKE_OUT = %w(date_of_birth(1i) date_of_birth(2i) date_of_birth(3i))

  def initialize(*args)
    args = args[0]
    if args
      date_hash = {year: args['date_of_birth(1i)'],
                   month: args['date_of_birth(2i)'],
                   day: args['date_of_birth(3i)']
      }
      date_of_birth = resolve_date(date_hash)
      @date_of_birth = date_of_birth
    end

    if args.class == Hash
      TAKE_OUT.each do |field|
        args.delete(field)
      end

      args.each do |k, v|
        send("#{k}=", v)
      end
    end
  end

  def resolve_date(hash)
    if hash.has_key?(:date_of_birth)
      if hash[:date_of_birth].class == String
        new_date = Date.parse(hash[:date_of_birth])
      else
        new_date = hash[:date_of_birth]
      end
    else
      if hash.values.compact.size == 0
        new_date = Date.new.change(year: 1950)
      else
        new_date = Date.new(hash[:year].to_i, hash[:month].to_i, hash[:day].to_i)
      end
    end
    new_date
  end

  def self.find(camper_id)
    camper = Camper.find(camper_id)
    if camper
      from_camper(camper)
    end
  end

  def self.to_camper(form_object)
    camper = Camper.new
    camper.is_admin = form_object.is_admin
    camper.email = form_object.email
    camper.confirm_email = form_object.confirm_email
    camper.phone_number = form_object.phone_number
    camper.allergy = form_object.allergy
    camper.confirm_phone_number = form_object.confirm_phone_number
    camper.first_name = form_object.first_name
    camper.last_name = form_object.last_name
    camper.other_names = form_object.other_names
    camper.gender = form_object.gender
    camper.nationality = form_object.nationality
    camper.arrival_day = form_object.arrival_day
    camper.arrival_time = form_object.arrival_time
    camper.departure_day = form_object.departure_day
    camper.residence = form_object.residence
    camper.role = form_object.role
    camper.emergency_contact = form_object.emergency_contact
    camper.emergency_number = form_object.emergency_number
    camper.date_of_birth = form_object.date_of_birth

    if form_object.church.downcase == 'other'
      camper.church ={
          type: 'other',
          name: form_object.other_church
      }
    else
      camper.church ={
          type: 'default',
          name: form_object.church
      }
    end

    if form_object.occupation.downcase == 'student'
      camper.occupation = {
          type: 'student',
          school_location: form_object.school_location,
          educational_level: form_object.educational_level
      }
      if form_object.school.blank?
        camper.occupation[:school] = form_object.other_school
        camper.occupation[:school_type] = 'other'
      else
        camper.occupation[:school] = form_object.school
        camper.occupation[:school_type] = 'default'
      end

      if form_object.school_location.blank?
        camper.occupation[:school_location_type]= 'other'
        camper.occupation[:school_location] = form_object.other_school_location
      else
        camper.occupation[:school_location_type]= 'default'
        camper.occupation[:school_location] = form_object.school_location
      end
    else
      camper.occupation = {type: 'worker'}
    end
    camper
  end


  def self.from_camper(camper)
    form_camper = CamperFormObject.new(nil, nil)
    form_camper.is_admin = camper.is_admin
    form_camper.email = camper.email
    form_camper.confirm_email = camper.confirm_email
    form_camper.phone_number = camper.phone_number
    form_camper.allergy = camper.allergy
    form_camper.confirm_phone_number = camper.confirm_phone_number
    form_camper.first_name = camper.first_name
    form_camper.last_name = camper.last_name
    form_camper.other_names = camper.other_names
    form_camper.gender = camper.gender
    form_camper.nationality = camper.nationality
    form_camper.arrival_day = camper.arrival_day
    form_camper.arrival_time = camper.arrival_time
    form_camper.departure_day = camper.departure_day
    form_camper.residence = camper.residence
    form_camper.role = camper.role
    form_camper.emergency_contact = camper.emergency_contact
    form_camper.emergency_number = camper.emergency_number
    form_camper.date_of_birth = camper.date_of_birth.class == String ? Date.parse(camper.date_of_birth) : camper.date_of_birth

    if camper.church['type'].downcase == 'default'
      form_camper.church = camper.church['name']
    else
      form_camper.church = 'Other' #watch this it can't be 'other' in small letters
      form_camper.other_church = camper.church['name']
    end

    if camper.occupation['type'].downcase == 'student'

      form_camper.educational_level = camper.occupation['educational_level']

      if camper.occupation['school_type'].downcase == 'other'
        form_camper.other_school = camper.occupation['school']
      else
        form_camper.school = camper.occupation['school']
      end

      if camper.occupation['school_location_type'].downcase == 'other'
        form_camper.other_school_location = camper.occupation['school_location']
      else
        form_camper.school_location = camper.occupation['school_location']
      end
    else
    end
    form_camper.occupation = camper.occupation['type']
    form_camper
  end

end
