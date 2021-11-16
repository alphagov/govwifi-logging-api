FactoryBot.define do
  factory :sessions, class: Session do
    to_create(&:save)

    username { SecureRandom.alphanumeric(6).downcase }
    success { true }
    start { Date.today }
    stop { nil }
  end
end
