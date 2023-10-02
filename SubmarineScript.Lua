-- Register the behaviour
--Atherline 5
--credit author
behaviour("SubmarineScript")
local Sub -- the actual sub object. only the floaters are outside of this object so the sub. seats. weapons go in here
local floatlevel
local minfloat
local killlock -- bot sub dive variable

function SubmaineScript:Start()
	self.Sub = self.targets.hull.gameObject
	self.floatlevel = self.targets.hull.transform.position.y
	self.killlock = false
end

function SubmaineScript:Update()
	if self.killlock == false then
		self.floatlevel = self.targets.hull.transform.position.y
		local ray = Ray(self.Sub.transform.position, Vector3.down)
		local raycast = Physics.Raycast(ray,1190, RaycastTarget.ProjectileHit)
		--print(raycast.distance)
		if Time.timeScale ~= 0.0 and self.gameObject.GetComponent(Vehicle).hasDriver and self.gameObject.GetComponent(Vehicle).driver == Player.actor then
			if Input.GetKeyBindButton(KeyBinds.Jump) and self.floatlevel <= Water.GetWaterLevel() then --go up if self less then water level 
				self.Sub.transform.position = Vector3(self.Sub.transform.position.x, self.Sub.transform.position.y + 0.05, self.Sub.transform.position.z)
			end
			if Input.GetKeyBindButton(KeyBinds.Crouch)then -- down
				if raycast ~= nil then--check distance from floor to stop sub from going down further
					if raycast.distance > 9 then
						self.Sub.transform.position = Vector3(self.Sub.transform.position.x, self.Sub.transform.position.y - 0.05, self.Sub.transform.position.z)
					end
				else
					self.Sub.transform.position = Vector3(self.Sub.transform.position.x, self.Sub.transform.position.y - 0.05, self.Sub.transform.position.z)
				end
			end
		end
		if Time.timeScale ~= 0.0 and self.gameObject.GetComponent(Vehicle).hasDriver and self.gameObject.GetComponent(Vehicle).driver ~= Player.actor then
			if raycast.distance ~= nil then -- go up
				if  not self.gameObject.GetComponent(Vehicle).isBeingLocked and self.gameObject.GetComponent(Vehicle).isTrackedByMissile == false and not self.gameObject.GetComponent(Vehicle).isBeingLocked and self.floatlevel <= Water.GetWaterLevel() then
					self.Sub.transform.position = Vector3(self.Sub.transform.position.x, self.Sub.transform.position.y + 0.01, self.Sub.transform.position.z)
					--print("u")
				end
				-- go down
				if self.gameObject.GetComponent(Vehicle).isBeingLocked and raycast.distance > 12 then
					self.Sub.transform.position = Vector3(self.Sub.transform.position.x, self.Sub.transform.position.y - 0.01, self.Sub.transform.position.z)
					--print("d")
				end
			end
		end
	end
	if self.killlock == false and self.targets.breaks.activeSelf == true then
		self.targets.breaks.transform.position = self.Sub.transform.position
		self.killlock = true
	end
end
