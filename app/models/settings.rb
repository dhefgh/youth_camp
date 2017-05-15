module Settings
  REGISTRATION_END_DATE = "2017-06-07"

  def Settings.registration_ended?
    Date.today > Date.parse(REGISTRATION_END_DATE)
  end
end
