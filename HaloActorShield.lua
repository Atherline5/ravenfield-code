-- Register the behaviour
behaviour("HaloActorShield")
local shieldhealth = 1000
local shields
local shieldsrl
local healthbartype
local hbarout
local Maxhealth
local armoren
local dmgdev
local chargehealth
local shhud
local carryover
local showshield
local justhit
local ischarnging
local addedshield
--local pausecharge
local colarr
local damgpart
local repart
local instance
local runningcharge
local lowshieldsound
local hittime
--local runningcharge
local countcharact
local delta1
local doautchar
--hit
local ang
local damind
local damsize
local sheildflash
local flashimg
local hithud
---Overshield
local overshield
local obvshobj
local OSH
local OSHRl
local uosh
local uoshl
local hasover
local enoversh
local listofosheq
local osmintwo
local osmx
local ossnd
local justover
local waitcharge

function HaloActorShield:Start()
	print("Started Halo Energy Shields Mutator")
	self.overshield = 0
	self.listofosheq = {}
	self.showshield = false
	self.justhit = false
	self.ischarnging = false
	self.healthbartype = self.script.mutator.GetConfigurationDropdown("hlfbr")
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
	self.chargehealth = self.script.mutator.GetConfigurationInt("shhlfm")
	self.shieldhealth = self.chargehealth
	self.overshield = self.script.mutator.GetConfigurationRange("ovrsh")
	self.osmx = self.script.mutator.GetConfigurationRange("osmax")
	self.waitcharge = self.script.mutator.GetConfigurationRange("srcounter")
	if self.overshield > 0 then
		self.hasover = true
	end
	self.hithud = self.targets.shhudY1
	self.hittime = Time.time
	self.doautchar = self.script.mutator.GetConfigurationBool("authel")
	self.armoren = self.script.mutator.GetConfigurationDropdown("armr")
	self.damsize = self.script.mutator.GetConfigurationRange("insize")
	self.enoversh = self.script.mutator.GetConfigurationBool("ovsheq")
	self.osmintwo = self.script.mutator.GetConfigurationBool("ovshtwo")
	self.shieldsrl = self.targets.chargerl
	self.ossnd = self.targets.ossound
	self.obvshobj = self.targets.overobj
	self.OSHRl = self.targets.ovshhrl
	self.uoshl = self.targets.olhrl
	self.hithud.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.shhudY.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.shhudR.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.shhudB.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	if self.script.mutator.GetConfigurationDropdown("huhitcolr") == 0 then
		self.shhud = nil
	end
	if self.script.mutator.GetConfigurationDropdown("huhitcolr") == 1 then
		self.shhud = self.targets.shhudY
	end
	if self.script.mutator.GetConfigurationDropdown("huhitcolr") == 2 then
		self.shhud = self.targets.shhudR
	end
	if self.script.mutator.GetConfigurationDropdown("huhitcolr") == 3 then
		self.shhud = self.targets.shhudB
	end
	if self.script.mutator.GetConfigurationDropdown("huhitcolr") ~= 0 then
		self.shhud.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	end
	if self.enoversh then
		for i,c in pairs(ActorManager.capturePoints) do
			--local lox = Random.Range(-3,3)
			for i = Random.Range(2,4),1,-1 do
				local ins = GameObject.Instantiate(self.obvshobj)
				ins.transform.position = Vector3(c.transform.position.x+Random.Range(-4,4),c.transform.position.y+5,c.transform.position.z+Random.Range(-4,4))
				table.insert(self.listofosheq,ins)
			end
		end
	end
	--print(self.damsize)
	if self.healthbartype == 0 then
		self.script.StartCoroutine("disableall")
		self.targets.chargerr.SetActive(true)
		self.targets.chargerl.SetActive(true)
		self.targets.boundr.SetActive(true)
		self.shields = self.targets.chargerr
		self.shieldsrl.SetActive(true)
		self.hbarout = self.targets.boundr
		self.flashimg = self.targets.lowhr
		--OvSh
		self.OSH = self.targets.ovshhrr
		self.uosh = self.targets.olhrr
	end
	if self.healthbartype == 1 then
		self.script.StartCoroutine("disableall")
		self.targets.bounddef.SetActive(true)
		self.targets.chargedef.SetActive(true)
		self.shields = self.targets.chargedef
		self.hbarout = self.targets.bounddef
		self.shieldsrl.SetActive(false)
		self.flashimg = self.targets.lowh3
		--OvSh
		self.OSH = self.targets.ovshh3
		self.uosh = self.targets.olh3	
	end
	if self.healthbartype == 2 then
		self.script.StartCoroutine("disableall")
		self.targets.charge4.SetActive(true)
		self.targets.bound4.SetActive(true)
		self.shields = self.targets.charge4
		self.hbarout = self.targets.bound4
		self.shieldsrl.SetActive(false)
		self.flashimg = self.targets.lowh4
		--OvSh
		self.OSH = self.targets.ovshh4
		self.uosh = self.targets.olh4
	end
	if self.healthbartype == 3 then
		self.script.StartCoroutine("disableall")
		self.targets.charge5.SetActive(true)
		self.targets.bound5.SetActive(true)
		self.shields = self.targets.charge5
		self.hbarout = self.targets.bound5
		self.shieldsrl.SetActive(false)
		self.flashimg = self.targets.lowh5
		--OvSh
		self.OSH = self.targets.ovshh5
		self.uosh = self.targets.olh5
	end
	if self.healthbartype == 4 then
		self.script.StartCoroutine("disableall")
		self.targets.chargei.SetActive(true)
		self.targets.boundi.SetActive(true)
		self.shields = self.targets.chargei
		self.hbarout = self.targets.boundi
		self.flashimg = self.targets.lowhi
		--OvSh
		self.OSH = self.targets.ovshhi
		self.uosh = self.targets.olhi
	end
	self.flashimg.SetActive(true)
	self.flashimg.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	
	if self.armoren == 0 then
		self.dmgdev = 0
	end
	if self.armoren == 1 then
		self.dmgdev = 0.9
	end
	if self.armoren == 2 then
		self.dmgdev = 0.75
	end
	if self.armoren == 3 then
		self.dmgdev = 0.6
	end
	if self.armoren == 4 then
		self.dmgdev = 0.5
	end
	self.colarr = {self.targets.holo}
	self.damgpart = self.targets.dampac
	self.repart = self.targets.rechpart
	self.instance = self
	self.runningcharge = false
	self.lowshieldsound = self.targets.lowsound
	self.countcharact = 0
	self.sheildflash = false
	self.justover = false
	self.script.StartCoroutine("updateindicator")
end

function HaloActorShield:disableall()
	self.targets.chargerr.SetActive(false)
	self.targets.chargerl.SetActive(false)
	self.targets.boundr.SetActive(false)
	self.targets.chargedef.SetActive(false)
	self.targets.bounddef.SetActive(false)
	self.targets.charge4.SetActive(false)
	self.targets.bound4.SetActive(false)
	self.targets.charge5.SetActive(false)
	self.targets.bound5.SetActive(false)
	self.targets.chargei.SetActive(false)
	self.targets.boundi.SetActive(false)
	self.targets.ovshhrr.SetActive(false)
	self.targets.ovshhrl.SetActive(false)
	self.targets.ovshh3.SetActive(false)
	self.targets.ovshh4.SetActive(false)
	self.targets.ovshh5.SetActive(false)
	self.targets.ovshhi.SetActive(false)
	self.targets.olhrr.SetActive(false)
	self.targets.olhrl.SetActive(false)
	self.targets.olh3.SetActive(false)
	self.targets.olh4.SetActive(false)
	self.targets.olh5.SetActive(false)
	self.targets.olhi.SetActive(false)
	self.targets.lowh3.SetActive(false)
	self.targets.lowhr.SetActive(false)
	self.targets.lowh4.SetActive(false)
	self.targets.lowh5.SetActive(false)
	self.targets.lowhi.SetActive(false)
	self.uoshl.SetActive(false)
	self.OSHRl.SetActive(false)
end

function HaloActorShield:OvershieldEquip()
	self.shields.gameObject.GetComponent(Image).fillAmount = 1
	if self.healthbartype == 0 then
		self.shieldsrl.gameObject.GetComponent(Image).fillAmount = 1
	end
	if not self.ossnd.GetComponent(AudioSource).isPlaying then
		self.ossnd.GetComponent(AudioSource).Play()
	end
	EffectUi.FadeIn(FadeType.FullScreen, 0.2, Color.green)
	coroutine.yield(WaitForSeconds(0.2))
	if not self.repart.GetComponent(AudioSource).isPlaying then
		self.repart.GetComponent(AudioSource).Play()
	end
	EffectUi.Clear()
	self.hithud.GetComponent(RawImage).CrossFadeAlpha(0, 0.2, false)
	--print("over")
end

function HaloActorShield:updateindicator()
	--reset ind
	self.targets.dam1.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam2.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam3.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam4.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam5.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam6.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam7.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam8.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam9.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam10.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam11.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	self.targets.dam12.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
	--print("done")
	--damsize
	self.targets.dam1.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam2.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam3.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam4.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam5.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam6.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam7.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam8.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam9.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam10.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam11.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.targets.dam12.GetComponent(RectTransform).localScale = Vector3(self.damsize,self.damsize,self.damsize)
	self.damind = self.targets.dam12
end

function HaloActorShield:StartCharge()
	self.runningcharge = true
	local loop = true
	if self.justover == false then
		coroutine.yield(WaitForSeconds(self.waitcharge))
	end
	self.justover = false
	--print("charging")
	--print("hit swo")
	if self.repart.GetComponent(AudioSource).isPlaying == false then
		self.repart.GetComponent(AudioSource).Play()
	end
	self.hithud.GetComponent(RawImage).CrossFadeAlpha(0.8, 0.2, false)
	while loop == true do
		--print("looped")
		if self.shieldhealth < self.chargehealth and Time.time > self.hittime + self.waitcharge and not Player.actor.isDead or self.justover == true then
			self.shieldhealth = self.shieldhealth + self.chargehealth*0.005
			--Player.actor.AddAccessory(self.targets.actshe, self.colarr)
			--print(self.shieldhealth)
			coroutine.yield(WaitForSeconds(0.01))
			Player.actor.balance = self.chargehealth * 2
			self.ischarnging = true
			if self.doautchar then
				if Player.actor.health < Player.actor.maxHealth then
						Player.actor.health = Player.actor.health + 0.5
				end
				if Player.actor.health > Player.actor.maxHealth then
					Player.actor.health = Player.actor.maxHealth
				end
			end
			if self.overshield == 0 and not Player.actor.isDead then
				--self.repart.GetComponent(AudioSource).Play()
				self.repart.GetComponent(ParticleSystem).Play()
			end
		else
			loop = false
			Player.actor.RemoveAccessories()
			--print("rem1")
			self.hithud.GetComponent(RawImage).CrossFadeAlpha(0, 0.2, false)
			self.shhud.GetComponent(RawImage).CrossFadeAlpha(0, 0.2, false)
			self.ischarnging = false
			--print("stop charge")
			self.countcharact = self.countcharact - 1
			self.runningcharge = false
			self.justover = false
		end
	end
	if self.shieldhealth > self.chargehealth then
		self.shieldhealth = self.chargehealth
	end
	if self.repart.GetComponent(ParticleSystem).isPlaying then
		self.repart.GetComponent(ParticleSystem).Stop()
	end
end

function HaloActorShield:indecator()
	--print("-------DAM--------")
	local thisdam
	if self.damind.name == "Image (11)" then
		thisdam = self.targets.dam1
		self.damind = self.targets.dam1
	elseif self.damind.name == "Image" then
		thisdam = self.targets.dam2
		self.damind = self.targets.dam2
	elseif self.damind.name == "Image (1)" then
		thisdam = self.targets.dam3
		self.damind = self.targets.dam3
	elseif self.damind.name == "Image (2)" then
		thisdam = self.targets.dam4
		self.damind = self.targets.dam4
	elseif self.damind.name == "Image (3)" then
		thisdam = self.targets.dam5
		self.damind = self.targets.dam5
	elseif self.damind.name == "Image (4)" then
		thisdam = self.targets.dam6
		self.damind = self.targets.dam6
	elseif self.damind.name == "Image (5)" then
		thisdam = self.targets.dam7
		self.damind = self.targets.dam7
	elseif self.damind.name == "Image (6)" then
		thisdam = self.targets.dam8
		self.damind = self.targets.dam8
	elseif self.damind.name == "Image (7)" then
		thisdam = self.targets.dam9
		self.damind = self.targets.dam9
	elseif self.damind.name == "Image (8)" then
		thisdam = self.targets.dam10
		self.damind = self.targets.dam10
	elseif self.damind.name == "Image (9)" then
		thisdam = self.targets.dam11
		self.damind = self.targets.dam11
	elseif self.damind.name == "Image (10)" then
		thisdam = self.targets.dam1
		self.damind = self.targets.dam1
	end
	if self.shhud~= nil then
		self.shhud.GetComponent(RawImage).CrossFadeAlpha(1, 0.2, false)
	end
	thisdam.GetComponent(RawImage).rectTransform.position = self.targets.dam1.GetComponent(RawImage).rectTransform.position
	thisdam.GetComponent(RawImage).CrossFadeAlpha(1, 0.2, false)
	thisdam.GetComponent(RawImage).rectTransform.rotation = Quaternion.Euler(0, 0, self.ang)
	Player.actor.AddAccessory(self.targets.actshe, self.colarr)
	coroutine.yield(WaitForSeconds(0.5))
	if self.shhud~= nil then
		self.shhud.GetComponent(RawImage).CrossFadeAlpha(0, 0.3, false)
	end
	--Player.actor.RemoveAccessories()
	--print("rem")
	thisdam.GetComponent(RawImage).CrossFadeAlpha(0, 0.6, false)
end

function HaloActorShield:onTakeDamage(act,scorce,info)
	if act == Player.actor then
		self.hittime = Time.time
		self.justhit = true
		if self.shieldhealth > 0 then
			CurrentEvent.Consume()
			self.ossnd.GetComponent(AudioSource).Stop()
			self.repart.GetComponent(AudioSource).Stop()
			self.damgpart.GetComponent(ParticleSystem).Play()
			Player.actor.AddAccessory(self.targets.actshe, self.colarr)
			--print("-------------------------------")
			local vect = PlayerCamera.activeCamera.transform.worldToLocalMatrix.MultiplyVector(-info.direction)
			self.ang = Mathf.Atan2(vect.z, vect.x) * 57.29578 - 90
			self.script.StartCoroutine("indecator")
			self.damgpart.GetComponent(AudioSource).Play()
		else
			if self.overshield == 0 and self.hasover == false then
				Player.actor.health = Player.actor.health + info.healthDamage * self.dmgdev
				Player.actor.balance = Player.actor.balance + info.balanceDamage * self.dmgdev
				print(info.healthDamage * self.dmgdev)
				Player.actor.RemoveAccessories()
			elseif self.overshield ~= 0 and self.hasover then
				CurrentEvent.Consume()
				self.overshield = self.overshield - 1
				self.shieldhealth = self.chargehealth
				if self.overshield == 0 then
					self.hasover = false
					self.OSH.SetActive(false)
					if self.healthbartype == 0 then
						self.OSHRl.SetActive(false)
					end
				end
			end
		end
	end
	--print(self.overshield)
	self.runningcharge = false
	--print(self.countcharact)
	self.shieldhealth = self.shieldhealth - info.healthDamage
	if self.shieldhealth < 0 then
		if self.overshield > 0 then 
			self.carryover =  self.shieldhealth
			self.overshield = self.overshield - 1
			self.shieldhealth = self.chargehealth + self.carryover
		else
			Player.actor.health = Player.actor.health + self.shieldhealth
			self.shieldhealth = 0
			--print("nope")
		end
	end
	if self.overshield == 0 then
		self.OSH.SetActive(false)
		self.uosh.SetActive(false)
		if self.healthbartype == 0 then
			self.OSHRl.SetActive(false)
			self.uoshl.SetActive(false)
		end
	end
	--print(self.chargehealth*0.3)
	--print(self.shieldhealth)
	if  self.overshield == 0 and self.sheildflash == false and self.shieldhealth < self.chargehealth*0.3 then
		self.sheildflash = true
		self.script.StartCoroutine("flashnoshield")
	end
	if self.overshield == 0 or self.overshield < 0 and self.shieldhealth < self.chargehealth and self.countcharact == 0 and not Player.actor.isDead and self.runningcharge == false then
		self.countcharact = self.countcharact + 1
		self.script.StartCoroutine("StartCharge")
		--print("Start Charge")
	end
	--print("HIT")
	--self.repart.GetComponent(ParticleSystem).Stop()
	--self.damgpart.GetComponent(ParticleSystem).Stop()
end

function HaloActorShield:flashnoshield()
	coroutine.yield(WaitForSeconds(0.04))
	--print(self.chargehealth * 0.3)
	if self.shieldhealth < self.chargehealth * 0.3 and not Player.actor.isDead then
		if self.lowshieldsound.GetComponent(AudioSource).isPlaying == false then
			self.lowshieldsound.GetComponent(AudioSource).Play()
		end
		self.flashimg.GetComponent(RawImage).CrossFadeAlpha(1, 0.2, false)
		coroutine.yield(WaitForSeconds(0.04))
		self.flashimg.GetComponent(RawImage).CrossFadeAlpha(0, 0.2, false)
		--print("loopflash")
		self.script.StartCoroutine("flashnoshield")
	else
		self.sheildflash = false
	end
end

function HaloActorShield:onActorSpawn(sact)
	if sact == Player.actor then
		Player.actor.balance = self.chargehealth
		self.shieldhealth = self.chargehealth
		self.hithud.GetComponent(RawImage).CrossFadeAlpha(0, 0, false)
		self.script.StartCoroutine("updateindicator")
		--print("spwn")
	end
end

--function HaloActorShield:onCapturePointCaptured()

--end

function HaloActorShield:Update()
	--print(PlayerCamera.isUsingOverrideCamera)
	if not Player.isSpectator and not Player.actor.isReadyToSpawn then
		if self.justhit and self.justhit and self and self.showshield == false and GameManager.isPaused then
			Player.actor.AddAccessory(self.targets.actshe, self.colarr)
			self.showshield = true
			--print("sd")
			self.justhit = false
		end
		if self.ischarnging and self and self.showshield == false and GameManager.isPaused then
			Player.actor.AddAccessory(self.targets.actshe, self.colarr)
			self.showshield = true
			--print("sds")
			self.justhit = false
		end
		if self.showshield and not GameManager.isPaused then
			Player.actor.RemoveAccessories()
			self.showshield = false
			--print("nd")
			self.addedshield = false
			self.justhit = false
		end
		if Player.actor.isDead and self.shields.gameObject.GetComponent(Image).fillAmount ~= 0 then
			self.shields.gameObject.GetComponent(Image).fillAmount = 0
		end
	end
	if not Player.actor.isReadyToSpawn and not Player.actor.isFallenOver and not Player.isSpectator and not Player.actor.isDriver then
		if self.shieldhealth ~= 0 then
			if GameManager.hudPlayerEnabled then
				if self.overshield > 0 and self.hasover == true and not self.OSH.activeSelf then
					self.OSH.SetActive(true)
					self.uosh.SetActive(true)
					if self.healthbartype == 0 then
						self.uoshl.SetActive(true)
					end
					--print("ov")
				end
				if self.targets.hitpar.activeSelf == false then
					self.targets.hitpar.SetActive(true)
					self.targets.dam1.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam2.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam3.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam4.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam5.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam6.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam7.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam8.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam9.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam10.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam11.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.targets.dam12.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
				end
				if self.shields.activeSelf == false and self.hbarout.activeSelf == false then
					self.shields.SetActive(true)
					self.hbarout.SetActive(true)
					if self.healthbartype == 0 then
						self.shieldsrl.SetActive(true)
					end
					--print("sh")
				else
					if self.shieldhealth > 0  then
						self.uosh.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
						self.OSH.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
						self.shields.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
						if self.healthbartype == 0 then
							self.shieldsrl.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
							self.OSHRl.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
							self.uoshl.gameObject.GetComponent(Image).CrossFadeAlpha(1, 0, true)
						end
						if self.overshield > 0  and self.hasover then
							self.uosh.SetActive(true)
							self.OSH.gameObject.GetComponent(Image).fillAmount = self.shieldhealth/self.chargehealth
							--print(self.OSH.gameObject.GetComponent(Image).fillAmount)
							if self.healthbartype == 0 then
								self.uoshl.SetActive(true)
								self.OSHRl.SetActive(true)
								self.OSHRl.gameObject.GetComponent(Image).fillAmount = self.shieldhealth/self.chargehealth
								if self.overshield == 1 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.red
									self.uoshl.gameObject.GetComponent(Image).color = Color.clear
									self.shields.gameObject.GetComponent(Image).fillAmount = 1
									self.shieldsrl.gameObject.GetComponent(Image).fillAmount = 1
								end
								if self.overshield == 2 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.green
									self.uoshl.gameObject.GetComponent(Image).color = Color.red
								end
								if self.overshield == 3 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.yellow
									self.uoshl.gameObject.GetComponent(Image).color = Color.green
								end
								if self.overshield == 4 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.blue
									self.uoshl.gameObject.GetComponent(Image).color = Color.yellow
								end
								if self.overshield == 5 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color(255/255,164/255,0/255)
									self.uoshl.gameObject.GetComponent(Image).color = Color.blue
								end
								if self.overshield == 6 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color(255/255,164/255,0/255)
									self.uoshl.gameObject.GetComponent(Image).color = Color(255/255,164/255,255/255)
								end
								if self.overshield == 7 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.cyan
									self.uoshl.gameObject.GetComponent(Image).color = Color(255/255,164/255,255/255)
								end
								if self.overshield == 8 then
									self.OSHRl.gameObject.GetComponent(Image).color = Color.magenta
									self.uoshl.gameObject.GetComponent(Image).color = Color.cyan
								end
							end
							if self.overshield == 1 then
								self.OSH.gameObject.GetComponent(Image).color = Color.red
								self.uosh.gameObject.GetComponent(Image).color = Color.clear
								self.shields.gameObject.GetComponent(Image).fillAmount = 100
							end
							if self.overshield == 2 then
								self.OSH.gameObject.GetComponent(Image).color = Color.green
								self.uosh.gameObject.GetComponent(Image).color = Color.red
							end
							if self.overshield == 3 then
								self.OSH.gameObject.GetComponent(Image).color = Color.yellow
								self.uosh.gameObject.GetComponent(Image).color = Color.green
							end
							if self.overshield == 4 then
								self.OSH.gameObject.GetComponent(Image).color = Color.blue
								self.uosh.gameObject.GetComponent(Image).color = Color.yellow
							end
							if self.overshield == 5 then
								self.OSH.gameObject.GetComponent(Image).color = Color(255/255,153/255,51/255)
								self.uosh.gameObject.GetComponent(Image).color = Color.blue
							end
							if self.overshield == 6 then
								self.OSH.gameObject.GetComponent(Image).color = Color(255/255,153/255,187/255)
								self.uosh.gameObject.GetComponent(Image).color = Color(255/255,153/255,51/255)
							end
							if self.overshield == 7 then
								self.OSH.gameObject.GetComponent(Image).color = Color.cyan
								self.uosh.gameObject.GetComponent(Image).color = Color(255/255,153/255,187/255)
							end
							if self.overshield == 8 then
								self.OSH.gameObject.GetComponent(Image).color = Color.magenta
								self.uosh.gameObject.GetComponent(Image).color = Color.cyan
							end
						else
							self.shields.gameObject.GetComponent(Image).fillAmount = self.shieldhealth/self.chargehealth
							if self.healthbartype == 0 then
								self.shieldsrl.gameObject.GetComponent(Image).fillAmount = self.shieldhealth/self.chargehealth
							end
						end
					else
						if self.overshield > 0 then
							self.shields.gameObject.GetComponent(Image).fillAmount = 1
							--print("emptyh")
							if self.healthbartype == 0 then
								self.shieldsrl.gameObject.GetComponent(Image).fillAmount = 0
								self.OSHRl.gameObject.GetComponent(Image).fillAmount = 0
								self.OSH.gameObject.GetComponent(Image).fillAmount = 0
							end
						else
							if Player.actor.isDead then
								self.shields.gameObject.GetComponent(Image).fillAmount = 0
							end
						end
					end
				end
			else
				if self.shields.activeSelf == true and self.hbarout.activeSelf == true then
					self.shields.SetActive(false)
					self.hbarout.SetActive(false)
					if self.healthbartype == 0 then
						self.shieldsrl.SetActive(false)
					end
					self.targets.shhudY.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.hithud.GetComponent(RawImage).CrossFadeAlpha(0, 0, true)
					self.uosh.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.shieldsrl.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.OSHRl.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.OSH.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.uoshl.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.shields.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					self.shieldsrl.gameObject.GetComponent(Image).CrossFadeAlpha(0, 0, true)
					if self.targets.hitpar.activeSelf == true then
						self.targets.hitpar.SetActive(false)
					end
				end
			end
			self.repart.transform.position = Vector3(Player.actor.centerPosition.x,Player.actor.centerPosition.y-1,Player.actor.centerPosition.z)
			self.damgpart.transform.position = Vector3(Player.actor.centerPosition.x,Player.actor.centerPosition.y+0.5,Player.actor.centerPosition.z)
		else
			self.shields.gameObject.GetComponent(Image).fillAmount = 0
			if self.healthbartype == 0 then
				self.shieldsrl.gameObject.GetComponent(Image).fillAmount = 0
			end
		end
		if self.enoversh and self.listofosheq ~= nil then
			--print("check")
			local scal = Vector3(1.5,3,1.5)
			for i,eq in pairs(self.listofosheq) do
				if Vector3.Distance(Player.actor.centerPosition, eq.transform.position) < 3 then
					if Bounds(eq.transform.position,scal).Contains(Player.actor.centerPosition) then
						--print("attempt")
						if self.osmintwo then
							if self.overshield == 0 then
								self.overshield = 2
								self.hasover = true
								local todelete = eq
								table.remove(self.listofosheq, i)
								GameObject.Destroy(todelete)	
								--print(self.overshield)
								self.justover = true
								self.script.StartCoroutine("OvershieldEquip")
								self.script.StartCoroutine("StartCharge")
							end
						else
							if self.overshield < 7 then
								self.overshield = self.overshield + 2
								local todelete = eq
								table.remove(self.listofosheq, i)
								GameObject.Destroy(todelete)		
								--print(self.overshield)
								self.hasover = true
								self.justover = true
								self.script.StartCoroutine("OvershieldEquip")
								self.script.StartCoroutine("StartCharge")
							end
						end
					end
				end
			end
		end
	end
	--print(self.shieldhealth)
	--print(self.justover)
	--if Input.GetKeyUp(KeyCode.J) then
		--local ins = GameObject.Instantiate(self.obvshobj)
		--table.insert(self.listofosheq,ins)
		--ins.transform.position = Player.actor.centerPosition
	--end
end