class User < Sequel::Model(:userdetails)
  User.unrestrict_primary_key
end
