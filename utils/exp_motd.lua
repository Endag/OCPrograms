local component = require("component")

if component.isAvailable("experience") == true then
	print("Current experience level " .. component.experience.level())
end