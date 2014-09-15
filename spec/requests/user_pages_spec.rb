require 'spec_helper'

describe 'User Pages' do

  subject { page }

  describe 'sign up page' do
    before { visit signup_path }
    it { expect(subject).to have_content('Sign Up') }
    it { expect(subject).to have_title(full_title('Sign Up'))}
  end
end
