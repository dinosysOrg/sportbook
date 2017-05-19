class ApplicationPage < SitePrism::Page
  section :navbar, NavbarSection, '.navbar'

  def switch_locale(locale)
    navbar.switch_locale locale
  end
end
