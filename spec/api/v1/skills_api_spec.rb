describe 'SkillsAPI' do
  it 'show all skills' do
    get '/api/v1/skills'
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:skills].count).to eq(Skill.count)
  end
end
