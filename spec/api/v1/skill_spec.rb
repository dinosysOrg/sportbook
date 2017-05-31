describe 'SkillsAPI' do
  let!(:skill) { create(:skill, name: 'professinal') }

  it 'show all skills' do
    create(:skill, name: 'good')
    get '/api/v1/skills'
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:skills].count).to eq(Skill.count)
    expect(json_response[:_embedded][:skills][0][:name]).to eq(skill.name)
  end
end
