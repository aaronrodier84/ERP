def add_user_to_all_zones(user)
  Zone.all.each {|zone| user.zones << zone }
  user.save!
end
