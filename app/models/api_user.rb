class ApiUser < User
  include DeviseTokenAuth::Concerns::User
end
