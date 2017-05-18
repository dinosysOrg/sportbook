describe 'SkillsAPI' do
  let!(:skill) { create(:skill, name: 'professinal') }

  it 'show all skills' do
    create(:skill, name: 'good')
    get '/api/v1/skills'
    expect(response.status).to eq(200)
    expect(json_response.count).to eq(2)
    expect(json_response[0][:name]).to eq(skill.name)
  end
end
