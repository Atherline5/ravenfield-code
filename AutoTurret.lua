-- heavy modded
behaviour("AutoTurret")

function AutoTurret:Start()
    self.scriptVar = self.script
    self.rotateableTurret = self.targets.turretbase -- Change these
    self.rotateableTurretGun = self.targets.gunbase -- Change these
    self.GunMuzzle = self.targets.muzzle1           -- Change these
    self.GunMuzzle2 = self.targets.muzzle2          -- Change these
    self.barrel = self.targets.barrel               -- Change these
    -- Enter the projectile speed
    self.rotationOffsetTurretBase = { 0, 0, 0 }     -- For yours its {-90,0,0} unless using the base APC turret
    self.rotationOffsetTurretGun = { 0, 0, 0 }

    self.attackActorsInRange = 3000
    self.turretBaseRotationSpeed = 15.2
    self.turretGunRotationSpeed = 6.2
    self.targetUntilEradicated = false -- Not used yet
    self.friendlyFire = false

    self.turretowner = Player.actor

    -- DO NOT CHANGE THESE VARIABLES
    --DATA CONTAINER Customisable
    self.projectileSpeed = self.gameObject.GetComponent(DataContainer).GetInt("projspeed")
    self.gunLead = self.gameObject.GetComponent(DataContainer).GetBool("lead")
    self.targetForSeconds = self.gameObject.GetComponent(DataContainer).GetInt("firetime")
    self.delayBetweenShots = self.gameObject.GetComponent(DataContainer).GetFloat("firerate")
    self.targetActors = self.gameObject.GetComponent(DataContainer).GetBool("targact")    -- Infantry
    self.targetVehicles = self.gameObject.GetComponent(DataContainer).GetBool("targvech") -- Vehicle
    self.starttrun = self.gameObject.GetComponent(DataContainer).GetBool("startturn")
    self.Animatebarrel = self.gameObject.GetComponent(DataContainer).GetBool("isanimatebarr")
    self.hasgroundround = self.gameObject.GetComponent(DataContainer).GetBool("hasantiground")
    self.WaitBetweenNewTargetAcquire = self.gameObject.GetComponent(DataContainer).GetInt("waittillfire")
    self.groundround = self.targets.groundproj
    --Script Variables only
    self.targetVehicleRigidbody = nil
    self.currentTarget = nil
    self.hasTarget = false -- Do not change this
    self.isShooting = false
    self.interceptPointX = nil
    self.interceptPointY = nil
    self.currentVehicleVel = nil
    self.doingSentry = false
    self.turnDeg = 0
    self.projectileGravity = self.targets.projectilePrefab.GetComponent(Projectile).gravityMultiplier
    self.proj1grav = self.targets.projectilePrefab.GetComponent(Projectile).gravityMultiplier
    if self.targets.groundproj ~= nil then
        self.proj2grav = self.targets.groundproj and self.targets.groundproj.GetComponent(Projectile).gravityMultiplier or
            1
    end
    --print(self.proj1grav)
    --print(self.proj2grav)
    if self.targetVehicles then
        local crb = self.gameObject.GetComponent(Rigidbody)
        if crb == nil then
            self.currentVehicleVel = Vector3.zero
        else
            self.currentVehicleVel = crb.velocity
        end
    end
    GameEvents.onActorDied.AddListener(self, "onActorDeath")
    self.script.StartCoroutine("turretstart")
end

function AutoTurret:OnActorDeath(actor)
    if self.currentTarget == actor then
        self.currentTarget = nil
    end
end

function AutoTurret:turretstart()
    if self.rotateableTurretGun.transform.localRotation.eulerAngles.x > 90 then
        self.rotateableTurretGun.transform.localRotation = Quaternion.RotateTowards(
            self.rotateableTurretGun.transform.localRotation,
            Quaternion.Euler(Vector3(self.rotateableTurretGun.transform.localRotation.eulerAngles.x + 90, 0, 0)),
            Time.deltaTime * 180)
        coroutine.yield(WaitForSeconds(0.01))
        self.script.StartCoroutine("turretstart")
    else
        return
    end
end

function AutoTurret:BarrelRecoil()
    if self.barrel ~= nil then
        --print("Recoil")
        self.barrel.GetComponent(Animator).SetTrigger("Fire")
        coroutine.yield(WaitForSeconds(0.2))
        self.barrel.GetComponent(Animator).ResetTrigger("Fire")
    else
        print("No barrel object")
    end
end

function AutoTurret:Shoot()
    self.isShooting = true
    local totaltime = self.targetForSeconds / self.delayBetweenShots
    print("priuntstart")
    for i = 1, totaltime, 1 do
        if self.currentTarget == nil or self.currentTarget.isDead then
            self.hasTarget = false
            self.isShooting = false
            return
        end
        if self.hasgroundround and self.targets.groundproj ~= nil then
            if ((self.currentTarget.isSeated == false and not self.currentTarget.isParachuteDeployed and not self.currentTarget.isOnLadder) or (self.currentTarget.isSeated and not self.currentTarget.activeVehicle.isAirplane and not self.currentTarget.activeVehicle.isHelicopter)) then
                self.projectileGravity = self.proj2grav
                local proj = GameObject.Instantiate(self.targets.groundproj)
                proj.transform.position = self.GunMuzzle.transform.position
                proj.transform.rotation = self.GunMuzzle.transform.rotation
                proj.GetComponent(Projectile).source = self.turretowner
                --print("[Drop Turrets] Fires mortar round")
            else
                self.projectileGravity = self.proj1grav
                local proj = GameObject.Instantiate(self.targets.projectilePrefab)
                proj.transform.position = self.GunMuzzle2.transform.position
                proj.transform.rotation = self.GunMuzzle2.transform.rotation
                proj.GetComponent(Projectile).source = self.turretowner
            end
        else
            self.projectileGravity = self.proj1grav
            local proj = GameObject.Instantiate(self.targets.projectilePrefab)
            proj.transform.position = self.GunMuzzle.transform.position
            proj.transform.rotation = self.GunMuzzle.transform.rotation
            proj.GetComponent(Projectile).source = self.turretowner
        end
        if self.GunMuzzle.GetComponentInChildren(AudioSource) ~= nil and not GameManager.isPaused then
            if self.GunMuzzle.GetComponentInChildren(AudioSource).isPlaying ~= true then
                self.GunMuzzle.GetComponentInChildren(AudioSource).Play()
            end
        end
        if self.GunMuzzle.GetComponentInChildren(ParticleSystem) ~= nil then
            self.GunMuzzle.GetComponentInChildren(ParticleSystem).Play()
        end
        if self.Animatebarrel then
            self.script.StartCoroutine("BarrelRecoil")
        end
        coroutine.yield(WaitForSeconds(self.delayBetweenShots))
    end
    self.isShooting = false
    coroutine.yield(WaitForSeconds(self.WaitBetweenNewTargetAcquire))
    self.hasTarget = false
end

function AutoTurret:TeamToNumber(team)
    if team == Team.Blue then
        return 0
    elseif team == Team.Red then
        return 1
    elseif team == Team.Neutral then
        return -1
    end
end

function AutoTurret:AcquireTarget()
    if self.rotateableTurret == nil then
        print("self.rotateableTurret is nil")
        return
    end
    if self.rotateableTurretGun == nil then
        print("self.rotateableTurretGun is nil")
        return
    end
    local actorsInRange = nil
    local tempArray = {}
    actorsInRange = ActorManager.AliveActorsInRange(self.gameObject.transform.position, self.attackActorsInRange)
    -- end
    for i, y in ipairs(actorsInRange) do
        if self.friendlyFire then
            table.insert(tempArray, y)
        end
        if y.team ~= Player.actor.team then
            table.insert(tempArray, y)
        end
    end
    actorsInRange = tempArray
    --print("CALL")
    local target = self:GetClosestActor(actorsInRange)
    if target ~= nil and self.hasTarget == false then
        --print("Acquiring target...")
        self.hasTarget = true
        self.scriptVar.StartCoroutine(self:EradicateActor(target))
    end
end

function AutoTurret:CalculateTrajectory(TargetDistance, ProjectileVelocitys)
    local n = (-Physics.gravity.y * TargetDistance * self.projectileGravity) --
    local b = ProjectileVelocitys * ProjectileVelocitys
    local CalculatedAngle = 0.5 * ((Mathf.Asin(n / (b * 0.98))) * Mathf.Rad2Deg)
    if (CalculatedAngle ~= CalculatedAngle) then
        return 0
    end
    return CalculatedAngle
end

function AutoTurret:EradicateActor(target)
    return function()
        if self.currentTarget ~= nil and self.currentTarget.gameObject == target.gameObject then
            self.hasTarget = false
            self.isShooting = false
            return
        end
        if target ~= nil then
            self.currentTarget = target
            if self.targetVehicles and target.activeVehicle ~= nil then
                self.targetVehicleRigidbody = target.activeVehicle.gameObject.GetComponentInChildren(Rigidbody)
                if self.targetVehicleRigidbody == nil then
                    self.hasTarget = false
                    self.isShooting = false
                    return
                end
            elseif not self.targetActors and target.activeVehicle == nil then
                self.hasTarget = false
                self.isShooting = false
                return
                --print("Invalid target type")
            end
            if self.hasTarget then
                self.script.StartCoroutine("Shoot")
            end
        else
            self.isShooting = false
            self.hasTarget = false
            print("Target is already dead")
        end
    end
end

function AutoTurret:tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function AutoTurret:GetClosestActor(ActorsInRange)
    local bestTarget = null;
    local closestDistanceSqr = Mathf.Infinity;
    local currentPosition = self.scriptVar.gameObject.transform.position
    for i, potentialTarget in ipairs(ActorsInRange) do
        local directionToTarget = potentialTarget.transform.position - currentPosition
        local ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
        local raycast = Physics.RaycastAll(ray, directionToTarget.magnitude - (directionToTarget.magnitude / 2) - 2,
            RaycastTarget.Opaque)
        local dSqrToTarget = directionToTarget.sqrMagnitude
        local size = self:tablelength(raycast)
        --Debug.DrawLine(self.rotateableTurretGun.transform.position, self.currentTarget.transform.position, Color.red)
        --print("tagr?")
        if size == 0 then
            if dSqrToTarget < closestDistanceSqr then
                closestDistanceSqr = dSqrToTarget;
                bestTarget = potentialTarget;
            end
        end
    end
    return bestTarget
end

function AutoTurret:FirstOrderIntercept(shooterPosition, shooterVelocity, shotSpeed, targetPosition, targetVelocity)
    local targetRelativePosition = targetPosition - shooterPosition
    local targetRelativeVelocity = targetVelocity - shooterVelocity

    local sqrMagnitude = targetRelativeVelocity.sqrMagnitude
    local t

    if sqrMagnitude < 0.001 then
        t = 0.0
    else
        t = self:FirstOrderInterceptTime(shotSpeed, targetRelativePosition, targetRelativeVelocity)

        -- Adjust lead time for fast moving targets at close range
        local distance = targetRelativePosition.magnitude
        local speed = targetVelocity.magnitude
        local closingSpeed = Vector3.Dot(targetRelativeVelocity, targetRelativePosition.normalized)
        if closingSpeed < 0 and distance < 15 and speed > 10 then
            t = t * Mathf.Clamp01((closingSpeed + 10) / 20)
        end
    end

    return targetPosition + t * targetVelocity
end

function AutoTurret:FirstOrderInterceptTime(shotSpeed, targetRelativePosition, targetRelativeVelocity)
    local velocitySquared = targetRelativeVelocity.sqrMagnitude
    if (velocitySquared < 0.001) then
        return 0.0
    end

    local a = velocitySquared - shotSpeed * shotSpeed

    -- Handle similar velocities
    if (Mathf.Abs(a) < 0.001) then
        local t = -Vector3.Dot(targetRelativePosition, targetRelativeVelocity) / velocitySquared
        return Mathf.Max(t, 0.0)
    end

    local b = 2 * Vector3.Dot(targetRelativeVelocity, targetRelativePosition)
    local c = targetRelativePosition.sqrMagnitude
    local determinant = b * b - 4 * a * c

    if (determinant > 0.0) then -- Determinant > 0; two intercept paths (most common)
        local t1 = (-b + Mathf.Sqrt(determinant)) / (2 * a)
        local t2 = (-b - Mathf.Sqrt(determinant)) / (2 * a)
        if (t1 > 0.0) then
            if (t2 > 0.0) then
                return Mathf.Min(t1, t2) -- Both are positive
            else
                return t1                -- Only t1 is positive
            end
        else
            return Mathf.Max(t2, 0.0) -- Don't shoot back in time
        end
    else
        if determinant < 0.0 then
            return 0.0
        else                                    -- Determinant = 0; one intercept path, pretty much never happens
            return Mathf.Max(-b / (2 * a), 0.0) -- Don't shoot back in time
        end
    end
end

function AutoTurret:searchingAnimation()
    if self.hasTarget == false and self.doingSentry == true then
        --print("sentry check")
        --print(self.turnDeg)
        while (self.hasTarget == false and self.hasTarget == false) do
            --print("sentry")
            --print("stop")
            if self.rotateableTurretGun.transform.localRotation.eulerAngles ~= Vector3(0, 0, 0) then
                self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(
                    self.rotateableTurretGun.transform.localRotation, Quaternion.Euler(Vector3(0, 0, 0)),
                    Time.deltaTime * self.turretGunRotationSpeed)
                --print(self.rotateableTurretGun.transform.localRotation)
            end
            self.turnDeg = 0
            coroutine.yield(WaitForSeconds(3.0))
            self.turnDeg = 90
            --print("180")
            coroutine.yield(WaitForSeconds(5.0))
            --print("stop")
            self.turnDeg = 0
            coroutine.yield(WaitForSeconds(3.0))
            --print("-180")
            self.turnDeg = -90
            coroutine.yield(WaitForSeconds(5.0))
        end
    end
end

function AutoTurret:Update()
    --print("-----")
    --print(self.hasTarget)
    --print(self.isShooting)
    if self.hasTarget and not self.gameObject.GetComponent(Vehicle).isBurning and self.currentTarget ~= nil then
        self.doingSentry = false
        -- CHECK IF ACTOR IS VISABLE
        -- print("lead")
        local lookPos1
        local lookPos2
        local tar = self.currentTarget.transform.position - self.GunMuzzle.transform.position
        if self.targetVehicles and self.currentTarget.activeVehicle ~= nil then
            --print("vech1")
            lookPos1 = self.currentTarget.transform.position - self.rotateableTurret.transform.position
            lookPos2 = self.currentTarget.transform.position - self.rotateableTurretGun.transform.position
        elseif self.targetActors and self.currentTarget.activeVehicle == nil then
            --print("act1")
            lookPos1 = self.currentTarget.position - self.rotateableTurret.transform.position
            lookPos2 = self.currentTarget.position - self.rotateableTurretGun.transform.position
            if self.currentTarget.isFallenOver then
                --print("look1a")
                lookPos1 = self.currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Chest).position -
                    self.rotateableTurretGun.transform.position
                lookPos2 = self.currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Chest).position -
                    self.rotateableTurretGun.transform.position
            end
        end
        local ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
        local raycast = Physics.RaycastAll(ray, tar.magnitude - (tar.magnitude / 2) - 2, RaycastTarget.Default) -- Time.frameCount%5 == 0 addition for performance reason
        local size = self:tablelength(raycast)
        if size ~= 0 then
            self.hasTarget = false
            return
        end
        self.hasTarget = true
        if self.gunLead then
            -- print("lead")
            --print(self.currentTarget.activeVehicle)
            if self.currentTarget.activeVehicle == nil and self.targetActors == true then
                --if self.targetActors and self.currentTarget.activeVehicle == nil then
                --print("act2")
                self.interceptPointY = self:FirstOrderIntercept(self.rotateableTurret.transform.position,
                    Vector3.zero, self.projectileSpeed, lookPos1, self.currentTarget.velocity)
                local calcTraj1 = self:CalculateTrajectory(
                    Vector3.Distance(self.rotateableTurret.transform.position, self.currentTarget.position),
                    (self.projectileSpeed))
                if calcTraj1 ~= 0 then
                    local trajectoryHeight = Mathf.Tan(calcTraj1 * Mathf.Deg2Rad) *
                        Vector3.Distance(self.rotateableTurret.transform.position, self.currentTarget.position)
                    if self.currentTarget.isParachuteDeployed then
                        trajectoryHeight = Vector3.Distance(self.rotateableTurretGun.transform.position,
                            self.currentTarget.position)
                    end
                    self.interceptPointY = Vector3(self.interceptPointY.x, self.interceptPointY.y + trajectoryHeight,
                        self.interceptPointY.z)
                end

                local rotation1 = Quaternion.LookRotation(self.interceptPointY)
                rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0) +
                    Vector3(self.rotationOffsetTurretBase[1], self.rotationOffsetTurretBase[2],
                        self.rotationOffsetTurretBase[3])) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
                self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation,
                    rotation1, Time.deltaTime * self.turretBaseRotationSpeed)
                self.interceptPointX = self:FirstOrderIntercept(self.rotateableTurretGun.transform.position,
                    Vector3.zero, self.projectileSpeed, lookPos2, self.currentTarget.velocity)
                local calcTraj2 = self:CalculateTrajectory(
                    Vector3.Distance(self.rotateableTurretGun.transform.position, self.currentTarget.position),
                    self.projectileSpeed)
                if calcTraj2 ~= 0 then
                    local trajectoryHeight = Mathf.Tan(calcTraj2 * Mathf.Deg2Rad) *
                        Vector3.Distance(self.rotateableTurretGun.transform.position, self.currentTarget.position)
                    self.interceptPointX = Vector3(self.interceptPointX.x, self.interceptPointX.y + trajectoryHeight,
                        self.interceptPointX.z)
                end
            elseif self.targetVehicles == true and self.currentTarget.activeVehicle ~= nil and self.targetVehicleRigidbody ~= nil then
                --[[print("vech2")
                    print(self.rotateableTurret.transform.position)
                    print(self.currentVehicleVel)
                    print(self.projectileSpeed)
                    print(lookPos1)
                    print(self.targetVehicleRigidbody.velocity)
                    print(self.interceptPointY)]]
                --local vectvel = Vector3
                --print(self.targetVehicleRigidbody.velocity)
                self.interceptPointY = self:FirstOrderIntercept(self.rotateableTurret.transform.position,
                    self.currentVehicleVel, self.projectileSpeed, lookPos1, self.targetVehicleRigidbody.velocity)
                local calcTraj1 = self:CalculateTrajectory(
                    Vector3.Distance(self.rotateableTurret.transform.position,
                        self.currentTarget.activeVehicle.gameObject.transform.position), self.projectileSpeed)
                if calcTraj1 ~= 0 then
                    local trajectoryHeight = Mathf.Tan(calcTraj1 * Mathf.Deg2Rad) *
                        Vector3.Distance(self.rotateableTurret.transform.position,
                            self.currentTarget.activeVehicle.transform.position)
                    self.interceptPointY = Vector3(self.interceptPointY.x, self.interceptPointY.y + trajectoryHeight,
                        self.interceptPointY.z)
                end
                local rotation1 = Quaternion.LookRotation(self.interceptPointY)
                rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0) +
                    Vector3(self.rotationOffsetTurretBase[1], self.rotationOffsetTurretBase[2],
                        self.rotationOffsetTurretBase[3])) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
                self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation,
                    rotation1, Time.deltaTime * self.turretBaseRotationSpeed)
                self.interceptPointX = self:FirstOrderIntercept(self.rotateableTurretGun.transform.position,
                    self.currentVehicleVel, self.projectileSpeed, lookPos2, self.targetVehicleRigidbody.velocity)
                local calcTraj = self:CalculateTrajectory(
                    Vector3.Distance(self.rotateableTurretGun.transform.position,
                        self.currentTarget.activeVehicle.gameObject.transform.position), self.projectileSpeed)
                if calcTraj ~= 0 then
                    local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) *
                        Vector3.Distance(self.rotateableTurretGun.transform.position,
                            self.currentTarget.activeVehicle.gameObject.transform.position)
                    self.interceptPointX = Vector3(self.interceptPointX.x, self.interceptPointX.y + trajectoryHeight,
                        self.interceptPointX.z)
                end
                --Debug.DrawLine(self.rotateableTurretGun.transform.position, self.currentTarget.activeVehicle.transform.position, Color.red)
                --Debug.DrawLine(self.rotateableTurretGun.transform.position, self.currentTarget.activeVehicle.transform.position + self.interceptPointX , Color.yellow)
            end
            local rotation2 = Quaternion.LookRotation(self.interceptPointX)
            local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0) +
                Vector3(self.rotationOffsetTurretGun[1], self.rotationOffsetTurretGun[2],
                    self.rotationOffsetTurretGun
                    [3]))
            self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(
                self.rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * self
                .turretGunRotationSpeed)
        else
            local rotation1 = Quaternion.LookRotation(lookPos1)
            rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0) +
                Vector3(self.rotationOffsetTurretBase[1], self.rotationOffsetTurretBase[2],
                    self.rotationOffsetTurretBase[3])) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
            self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation,
                rotation1, Time.deltaTime * self.turretBaseRotationSpeed)
            local rotation2 = Quaternion.LookRotation(lookPos2)
            local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0) +
                Vector3(self.rotationOffsetTurretGun[1], self.rotationOffsetTurretGun[2],
                    self.rotationOffsetTurretGun
                    [3]))
            self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(
                self.rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * self
                .turretGunRotationSpeed)
        end
        if raycast.point ~= nil then
            local isinsightline = Vector3.Distance(raycast.point, self.currentTarget.transform.position)
            if isinsightline > 20 then
                self.hasTarget = false
            end
        end
    else
        if self.doingSentry == false and self.isShooting == false then
            self.doingSentry = true
            self.script.StartCoroutine("searchingAnimation")
            if self.GunMuzzle.GetComponentInChildren(AudioSource) ~= nil then
                --if not self.GunMuzzle.GetComponentInChildren(AudioSource).isPlaying then
                self.GunMuzzle.GetComponentInChildren(AudioSource).Stop()
                --end
            end
            print("doing sentry")
            -- Debug.DrawLine(Player.actor.centerPosition, self.gameObject.transform.position, Color.red)
        end
        -- Debug.DrawLine(Player.actor.centerPosition, self.gameObject.transform.position, Color.red)
        --print(self.turnDeg)
        if self.turnDeg ~= 0 then
            --print("rot")
            self.rotateableTurret.transform.localRotation = Quaternion.RotateTowards(
                self.rotateableTurret.transform.localRotation,
                Quaternion.Euler(Vector3(self.rotateableTurret.transform.localRotation.eulerAngles.x,
                    self.rotateableTurret.transform.localRotation.eulerAngles.y + self.turnDeg,
                    self.rotateableTurret.transform.localRotation.eulerAngles.z)), Time.deltaTime * 20)
            --print("rotate1")
        end
        self.script.StartCoroutine("AcquireTarget")
    end
end
