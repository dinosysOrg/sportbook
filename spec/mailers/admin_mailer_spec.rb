describe AdminMailer do
  describe '#notify_unconfirmed_matches' do
    let(:groups) { create_list :group, 2 }
    let(:matches) do
      groups.map do |g|
        create_list :match, 2, group: g, time: nil
      end.flatten
    end

    it 'does not send email if no admin' do
      AdminMailer.notify_unconfirmed_matches(matches).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'shows groups & matches' do
      admins = create_list :admin_user, 2
      email = AdminMailer.notify_unconfirmed_matches matches

      expect(email).to deliver_to(admins.map(&:email))

      groups.each do |g|
        expect(email).to have_body_text(g.name)
      end

      matches.each do |m|
        expect(email).to have_body_text(m.code)
      end
    end
  end
end
