require 'spec_helper'

describe GpgKeys::CreateService do
  let(:user) { create(:user) }
  let(:params) { attributes_for(:gpg_key) }

  subject { described_class.new(user, params) }

  context 'notification', :mailer do
    it 'sends a notification' do
      perform_enqueued_jobs do
        subject.execute
      end
      should_email(user)
    end
  end

  it 'creates a gpg key' do
    expect { subject.execute }.to change { user.gpg_keys.where(params).count }.by(1)
  end
end