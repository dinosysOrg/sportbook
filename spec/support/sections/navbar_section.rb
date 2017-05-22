class NavbarSection < SitePrism::Section
  def switch_locale(locale)
    find("[data-test='locale-#{locale}']").click
  end
end
