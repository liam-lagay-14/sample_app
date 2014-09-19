require 'spec_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { expect(subject).to be_valid }

  describe 'follower methods' do
    it { expect(subject).to respond_to(:follower) }
    it { expect(subject).to respond_to(:followed) }

    its(:follower) { should eq follower }
    its(:followed) { should eq followed }
  end

  describe 'when followed id is not present' do
    before { subject.followed_id = '' }
    it { expect(subject).to_not be_valid }
  end

  describe 'when follower id is not present' do
    before { subject.follower_id = '' }
    it { expect(subject).to_not be_valid }
  end
end
