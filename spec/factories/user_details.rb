FactoryBot.define do
  factory :user_details, class: User do
    to_create(&:save)

    username { SecureRandom.alphanumeric(6).downcase }

    sequence :contact, 1 do |n|
      "username#{n}@domain.uk"
    end

    sequence :sponsor, 1 do |n|
      "sponsor#{n}@domain.uk"
    end

    password { SecureRandom.alphanumeric(10).downcase }
    notifications_opt_out { 0 }
    survey_opt_out { 0 }
    last_login { Date.today }
    created_at { Date.today }
    updated_at { Date.today }

    trait :email do
      transient do
        sequence :email_address, 1 do |n|
          "self_signed#{n}@domain.uk"
        end
      end
      contact { email_address }
      sponsor { email_address }
    end

    trait :sponsored do
      transient do
        sequence :sponsor_address, 1 do |n|
          "sponsor_address#{n}@domain.uk"
        end
      end

      sponsor { sponsor_address }
    end

    trait :sms do
      transient do
        sequence :phone_number, 1 do |n|
          "+4477#{sprintf('%08d', n)}"
        end
      end
      contact { phone_number }
      sponsor { phone_number }
    end

    trait :active do
      last_login { Date.today }
    end

    trait :inactive do
      last_login { nil }
    end
  end
end
