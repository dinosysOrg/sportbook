feature 'Internationalization' do
  scenario 'switching locale' do
    page = HomePage.new
    page.load

    expect(page).to have_content('Welcome')
    page.switch_locale(:vi)
    expect(page).to have_content('Xin chào')
  end
end
