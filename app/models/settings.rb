module Settings
  REGISTRATION_END_DATE = "2016-06-10"

  def Settings.registration_ended?
    Date.today > Date.parse(REGISTRATION_END_DATE)
  end
end
