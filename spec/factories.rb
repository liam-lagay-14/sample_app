FactoryGirl.define do
  factory :user do
    name                  'Liam Lagay'
    email                 'liam.lagay@gmail.com'
    password              'foobar'
    password_confirmation 'foobar'
  end
end