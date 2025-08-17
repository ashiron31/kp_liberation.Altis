//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/* 


	SUICIDAL DOCTRINE (Version 1.3)
	by thy (@aldolammel)
	Important: you need CBA+ACE mods.
	
	Github: https://github.com/aldolammel/Arma-3-Suicidal-Doctrine-Script
	Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2739692983
	Discussion: https://forums.bohemia.net/forums/topic/237502-release-suicidal-doctrine-script/
	AI behavior guide: on readme file.
	

	
*/
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

private ["_debugMonitor","_suicidalMethod","_deathShout","_suicidalEnemy","_suicidalTargets","_specialTarget","_suicidal","_vbied","_vbiedAmmo","_weldedDoors","_suicidalCanDrive","_vbiedNoWreck","_isVbiedInfinityFuel","_tryToFindSignal","_remoteTriggerRange","_vbiedActRange","_vbiedDeadRange","_dmtVestIed","_dmtVestIedAmmo","_dmtActRange","_dmtDeadRange","_csbVestIed","_csbVestIedAmmo","_csbActRange","_csbDeadRange","_csbVestDetonated","_vbiedDetonated","_dmtVestDetonated","_isSignalOn","_targetDistance","_isSuicidalCuffed","_isDmtVestActivated","_threatPos","_targetNearest","_onboardForever","_bNorth","_bEast","_bSouth","_bWest"]; 

//if (!hasInterface) exitWith {};     // if is NOT a player, get out! P.S: this line is no needed if you're calling the suicidalDoctrine.sqf through the initPlayerLocal.sqf

// EDITOR OPTIONS:

	// Debug monitors:
		_debugMonitor       = true;     // ............. true = show the debug monitor only on server/player hosting / false = off.
		
	// Basic config:
		_suicidalMethod     = 3;     // ................ 1 = vbied will be the suicidal method / 2 = deadman trigger / 3 = classic suicide bomber
		_deathShout         = "suicideCry";     // ..... sound name (sounds folder and description.ext file) of the suicidal cry.
		_suicidalTargets    = 1;     // ................ 0 = suicidal attack any enemy / 1 = only playables / 2 = only players / 3 = only one target.
			_suicidalEnemy  = blufor;     // ........... sets who is the suicidal enemy side: blufor / opfor / independent / civilian.
			_specialTarget  = theTarget;     // ........ a object, vehicle or unit name that's the target valid only for option number 3 above.
		_suicidal           = "LOP_ISTS_OPF_Infantry_Engineer";     // ......... who will be the suicidal unit, the unit name.
		
	// Vbied method config:
		_vbied              = vbied01;     // .......... which vehicle is vbied, the vehicle name.
		_vbiedAmmo          = "Bomb_04_F";     // ...... what's vbied's explosive, ammo name.
		_weldedDoors        = true;     // ............. true = doors are welded, if suicidal onboard, cant getout; if out, will use the remote-trigger / false = not welded. 
		_suicidalCanDrive   = true;     // ............. true = yes / false = no.if the suicide can take the wheel.
		_vbiedNoWreck       = false;     // ............ true = delete the wreck immediately after the explosion / false = by mission performance settings.
		_isVbiedInfinityFuel = true;     // ............ true = vbied has infinity fuel / false = limited fuel.
		_tryToFindSignal    = true;     // ............. true = suicidal will try to find the signal if they're out of vbied / false = don't try.
		_remoteTriggerRange = 1000;     // ............. suicidal remote-trigger range when (and if) out of vbied. Default is 1000 meters.
		_vbiedActRange      = 200;     // .............. suicidal in this method detects any target in this range. Default is 200 meters.
		_vbiedDeadRange     = 20;     // ............... limit range from the target to suicidal detonate their explosives. Default is 20 meters.
		
	// Deadman Trigger method config:
		_dmtVestIed     = "V_Chestrig_blk";     // ..... which vest will contain the explosive, the vest name.
		_dmtVestIedAmmo = "Rocket_03_HE_F";     // ..... what's vest's explosive, the ammo name.
		_dmtActRange    = 80;     // ................... suicidal in this method detects any target in this range. Default is 80 meters.
		_dmtDeadRange   = 10;     // ................... Limit range from the target to suicidal detonate their explosives. Default is 10 meters.
		
	// Classic suicide bomber method config:
		_csbVestIed = "V_HarnessOGL_gry";     // ....... which vest will contain the explosive, the vest name.
		_csbVestIedAmmo = "Rocket_04_HE_F";     // ..... what's classic vest's explosive, the ammo name.
		_csbActRange    = 150;     // ................... suicidal in this method detects any target in this range. Default is 80 meters.
		_csbDeadRange   = 10;     // ................... Limit range from the target to suicidal detonate their explosives. Default is 10 meters.


// CORE / TRY TO DO NOT CHANGE ANYTHING BELOW:

	// General:
		_suicidal enableDynamicSimulation false;     // .............. prevents the suicidal from having the feature turned on.
		removeAllWeapons _suicidal;     // ........................... forces the removal of any weapons from the suicidal.
		_suicidal setBehaviour "AWARE";     // ....................... forces the suicidal to pay attention.
		_suicidal setCombatMode "GREEN";     // ...................... force the suicidal to never fire, keep formation.
		_targetNearest = objNull;     // ............................. by default, the suicidal has no a target.
		_targetDistance = [];     // ................................. array where it will load with target distances of threat.
		waitUntil {sleep 1; allPlayers isNotEqualTo []};     // ...... waiting until we have player(s) available. 
		_isSuicidalCuffed = false;     // ............................ sets suicidal as not handcuffed.
		
	// Vbied method:
		_vbied enableDynamicSimulation 	false;     // ................ prevents vbied from having the feature turned on.
		_vbiedDetonated = false;     // .............................. sets vbied to undetonated yet.
		_onboardForever	= false;     // .............................. sets suicidal to not onboard yet.
		_isSignalOn = false;     // .................................. sets the suicidal remote-trigger signal off.
		
	// Deadman trigger method:
		_dmtVestDetonated = false;     // ............................ sets release-trigger vest to undetonated yet.
		_isDmtVestActivated = false;     // .......................... sets the explosive vest to start off.
		
	// Classic suicide bomber:
		_csbVestDetonated = false;     // ............................ sets classic-trigger vest to undetonated yet.
	
	
	
	
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/* 

	1) VBIED METHOD (Vehicle-bomb)
	
*/
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	
	
While {_suicidalMethod == 1} do     // Looping while: se doctrine method is vbied, do it:
{
	if (_debugMonitor == true) then     // if debug on, so...
	{		
		// show info on screen:
		hint format ["\n\nVBIED METHOD\n\n- - - - - -\n\nSUICIDAL MONITOR:\n\n%1, %2, %3 and %4.\n\nCan drive = %7.\n\nTrigger signal available = %5\n\nSignal range = %9m.\n\nAction range = %10m.\n\nPull the trigger range = %11m.\n\n- - - - - -\n\nTARGET MONITOR:\n\nWho's the enemy = %14.\n\nEnemy target is = %13\n(0=any / 1=playables / 2=onlyPlayers / 3=specialOne).\n\nNearest target = %12.\n\n- - - - - -\n\nVBIED MONITOR:\n\nDoors welded = %6.\n\nDetonation = %8.\n\nNo wreck = %15.\n\n", lifeState _suicidal, behaviour _suicidal, combatMode _suicidal, speedMode _suicidal, _isSignalOn, _weldedDoors, _suicidalCanDrive, _vbiedDetonated,_remoteTriggerRange,_vbiedActRange,_vbiedDeadRange,_targetNearest,_suicidalTargets, _suicidalEnemy, _vbiedNoWreck];
	};
	
	if (alive _suicidal) then     // if the suicidal is alive, so...
	{
		_suicidal allowFleeing 0;     // suicidal is not panic.
		
		if (_suicidalTargets != 3) then     // if the suicidal focus is NOT just one special target, so...
		{
			_threatPos = getPosATL _vbied;     // takes the current vbied position. 
			
			if (_suicidalTargets == 2) then     // if the suicidal consider only enemy players as potential targets.
			{
				// pick up the dist from each enemy alive to vbied and load the array with the distances: 
				_targetDistance = (allPlayers select {alive _x}) apply {[_x distanceSqr _threatPos, _x]}; 	
			};
			
			if (_suicidalTargets == 1) then     // if the suicidal consider enemy players and playable units as potential targets.
			{
				// Warning: if your mission has AI disable and _suicidalTargets is = 1, you'll face an error.
				_targetDistance = (playableUnits select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			if (_suicidalTargets == 0) then     // if the suicidal consider all enemy units (player, playable unit, regular unit) as potential targets.
			{
				// PERFORMANCE KILLER WHEN TOO MUCH TARGETS
				_targetDistance = ((units _suicidalEnemy) select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			_targetDistance sort true;     // sort the distances in array from smallest to biggest. 
			_targetNearest = _targetDistance #0#1;     // the closest target (player, for example) is in the _targetDistance array first position.
		
		} else     // if the suicidal focus finally is just one special target, do...
		{
			_targetNearest = _specialTarget;     // the nearest target is the only one: _specialTarget.
			sleep 2;     // execution breath.
		};
		
		if ((_vbied distance _suicidal) <= _remoteTriggerRange) then     // if distante between the suicidal and vbied is equal or less than remote-trigger range, so...
		{
			_isSignalOn = true;     // has signal.		
			
			if ( !(_suicidal in _vbied) and (_weldedDoors == false)) then     // if suicidal is NOT into vbied, and vbied isn't its doors welded, then...
			{
				_wp = group _suicidal addWaypoint [position _vbied, 0];     // creating the waypoint to vbied;
				_wp waypointAttachVehicle _vbied;     // creating the waypoint to vbied;
				_wp setWaypointType "GETIN";     // creating the waypoint to vbied;
			};
			
		} else     // if suicidal if too far away, do it...
		{
			if (_tryToFindSignal == true) then     // if suicidal is allowed to find out the signal, so...
			{
				_suicidal setBehaviour "AWARE";     // suicidal no longer cares about their own safety.
				_suicidal setCombatMode "GREEN";     // suicidal holds fire, keep formation
				_suicidal setSpeedMode "LIMITED";     // suicidal moves not too fast.
				_suicidal move getPos _vbied;     // suicidal moves to vbied arounds, but out of explosion range.
			};
		};
		
		if (_suicidal getVariable ["ace_captives_isHandcuffed", false]) then     // if the suicidal is handcuffed, then...
		{
			_isSuicidalCuffed = true;     // understand that suicidal is handcuffed.
			_isSignalOn = false;     // remote trigger signal is cut off.
			removeGoggles _suicidal;     // removes any cosmetic from the suicidal's face.
			removeHeadgear _suicidal;     // removes any cosmetic from the suicidal head.
			//removeAllAssignedItems _suicidal;     // Unassigns and deletes all linked items from inventory.
			removeAllContainers _suicidal;     // removes backpack, vest and uniform.
				//removeBackpack _suicidal;     // remove the backpack.
				//removeVest _suicidal;     // remove the vest.
				//removeUniform _suicidal;     // remove the uniform.
					
			_suicidal addGoggles "G_Blindfold_01_white_F";     // adds a blindfold over the suicide's eyes;
		};
		
	
		// ACTION RANGE
		if ((!isNull _targetNearest) and ((_targetNearest distance _vbied) <= _vbiedActRange)) then     // if there's a target and it's inside the suicidal action range, so... 
		{				
			if (_suicidal in _vbied) then     // if suicidal is inside vbied, then...
			{	
				_onboardForever = true;     // from now, suicidal will never step alive out from the vbied again.
				_suicidal setBehaviour "CARELESS";     // suicidal no longer cares about their life.
				
				if (_suicidalCanDrive == true) then     // if the suicidal can drive, then...
				{						
					if ((driver (vehicle _suicidal)) isEqualTo _suicidal ) then     // if the suicidal in vbied driver position then...
					{
						_suicidal setBehaviour "CARELESS";     // suicidal no longer cares about their own safety.
						_suicidal setSpeedMode "FULL";     // suicidal moves at full speed...
						_suicidal move getPos _targetNearest;     // up the target.
					};

					if ((_vbied distance _targetNearest) <= (_vbiedDeadRange + 10)) then     // if target is almost at _vbiedDeadRange (plus a few meters of margin), then...
					{
						_suicidal directSay _deathShout;     // suicidal screams.
					};
				} else     // If suicidal can't drive, do it...
				{
					// to leave the driver position empty = WIP, SOON!
					_vbied lockDriver true;     // lock driver position.
				};
								
			} else     // if suicidal is on foot, do...
			{
				// Trying "to fix" an Arma 3 annoying behavior that makes units leave the veh when it's brutally attacked: 
				if (_onboardForever == true) then     // if suicidal already in vbied but they try to get out, so...
				{
					_bNorth = _vbied getRelPos [8,0];     // adding Xm from north position of the vbied.
					_bEast 	= _vbied getRelPos [8,90];     // adding Xm from east position of the vbied. 
					_bSouth	= _vbied getRelPos [8,180];     // adding Xm from south position of the vbied.  
					_bWest 	= _vbied getRelPos [8,270];     // adding Xm from west position of the vbied. 
					_vbiedAmmo createVehicle getPos _vbied;     // a bomb is created at the vbied's top position, boom!
					_vbiedAmmo createVehicle _bNorth;     // a bomb is created at the vbied's north position, boom! 
					_vbiedAmmo createVehicle _bEast;     // a bomb is created at the vbied's east position, boom! 
					_vbiedAmmo createVehicle _bSouth;     // a bomb is created at the vbied's south position, boom!
					_vbiedAmmo createVehicle _bWest;     // a bomb is created at the vbied's west position, boom! 				
					
					_vbiedDetonated = true;     // sets vbied as detonated.
					deleteVehicleCrew _vbied;     // the vbied crew team is deleted.
					deleteVehicle _suicidal;     // delete the suicidal that jumps out.						
					sleep 0.1;     // execution breath.
					_suicidalMethod != 1;     // Stoping the While/loop of this method.
				};
				
				if ((_suicidal distance _targetNearest) <= (_vbiedDeadRange + 30)) then     // if the target is almost at _vbiedDeadRange (plus a few meters of margin), then...
				{
					_suicidal setBehaviour "COMBAT";     // suicidal enter combat mode.
					_suicidal setCombatMode "RED";     // suicidal fire at will, engage at will/loose formation.
					_suicidal allowFleeing 1;     // the suicidal gets panic.
				};
			};
			
			
			// DEAD RANGE			
			if ((_vbied distance _targetNearest) <= _vbiedDeadRange) then     // if distance between vbied and target is less than or equal to XXm, then...
			{	
				// if the suicide is conscious, has trigger signal, is uncuffed and vbied has NOT already exploded:
				if ((lifeState _suicidal == "HEALTHY") and (_isSignalOn == true) and (_isSuicidalCuffed == false) and (_vbiedDetonated == false)) then     // then...
				{
					_suicidal directSay _deathShout;     // suicidal screams.
					sleep 0.3;     // waits a while before the next action.
					
					_bNorth = _vbied getRelPos [8,0];     // adding Xm from north position of the vbied.
					_bEast 	= _vbied getRelPos [8,90];     // adding Xm from east position of the vbied. 
					_bSouth	= _vbied getRelPos [8,180];     // adding Xm from south position of the vbied.  
					_bWest 	= _vbied getRelPos [8,270];     // adding Xm from west position of the vbied. 
					_vbiedAmmo createVehicle getPos _vbied;     // a bomb is created at the vbied's top position, boom!
					_vbiedAmmo createVehicle _bNorth;     // a bomb is created at the vbied's north position, boom! 
					_vbiedAmmo createVehicle _bEast;     // a bomb is created at the vbied's east position, boom! 
					_vbiedAmmo createVehicle _bSouth;     // a bomb is created at the vbied's south position, boom!
					_vbiedAmmo createVehicle _bWest;     // a bomb is created at the vbied's west position, boom! 
					
					_vbiedDetonated = true;     // sets vbied as detonated.
					
					if (_suicidal in _vbied) then     // if suicidal inside vbied, so...
					{
						deleteVehicleCrew _vbied;     // the suicidal is deleted (dead or not).
					};
					sleep 0.1;     // execution breath.
					_suicidalMethod != 1;     // Stoping the While/loop of this method.
				};
			};
		};
	} else     // if the suicidal is NOT alive, do:
	{
		_suicidal directSay "";     // shut up.
	};
	
	if (alive _vbied) then     // if vbied is working, then...
	{										
		_vbied setUnloadInCombat [true, false];     // [cargo,turrets] the vbied crew isn't able to dismount from the main cabin. If there are units in the cargo, they can.
		
		if (_weldedDoors == true) then     // if the doors were welded then...
		{
			_vbied setVehicleLock "LOCKED";     // force lock vbied doors.
			_vbied allowCrewInImmobile true;     // crew can be in the vehicle with broken wheels.
		
		} else     // if the doors weren't welded, so...
		{
			_vbied setVehicleLock "UNLOCKED";     // unlock vehicle, preventing any choices made in the EDEN editor.
		};
		
		if (_isVbiedInfinityFuel == true) then     // if vbied fuel is infinite then...
		{ 	
			
			if (fuel _vbied < 0.5) then     // when the fuel is low then...
			{
				_vbied setFuel 1;     // fill up the vbied's fuel tank.
			};
		};
		
		if ((damage _vbied) > 0.9) then     // if the vbied is about to blows up, then...
		{
			sleep 0.3;     // waits a while before the next action.
			
			_bNorth = _vbied getRelPos [8,0];     // adding Xm from north position of the vbied.
			_bEast 	= _vbied getRelPos [8,90];     // adding Xm from east position of the vbied. 
			_bSouth	= _vbied getRelPos [8,180];     // adding Xm from south position of the vbied.  
			_bWest 	= _vbied getRelPos [8,270];     // adding Xm from west position of the vbied. 
			_vbiedAmmo createVehicle getPos _vbied;     // a bomb is created at the vbied's top position, boom!
			_vbiedAmmo createVehicle _bNorth;     // a bomb is created at the vbied's north position, boom! 
			_vbiedAmmo createVehicle _bEast;     // a bomb is created at the vbied's east position, boom! 
			_vbiedAmmo createVehicle _bSouth;     // a bomb is created at the vbied's south position, boom!
			_vbiedAmmo createVehicle _bWest;     // a bomb is created at the vbied's west position, boom! 
			
			_vbiedDetonated = true;     // sets vbied as detonated.
		
			if (_suicidal in _vbied) then     // if suicidal is inside vbied then...
			{
				deleteVehicleCrew _vbied;     // delete the vbied crew team.
			};
			
			sleep 0.1;     // execution breath.
			_suicidalMethod != 1;     // Stoping the While/loop of this method.
		};
	} else     // if the vbied is NOT working anymore, do...
	{
		if (_vbiedNoWreck == true) then     // if editor choose to remove the vbied wreck immediately after explosion, so...
		{
			deleteVehicle _vbied;     // delete the vbied.
		};
	};
	sleep 1;     // a looping breath.
};	
	
	
	
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/* 

	2) DEADMAN TRIGGER METHOD (Release-trigger)
	
*/
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	
		
While {_suicidalMethod == 2} do     // Looping while: se doctrine method is dead man trigger, do it:
{
	if (_debugMonitor == true) then     // if debug on, so...
	{
		// show info on screen:
		hint format ["\n\nDEADMAN TRIGGER METHOD\n\n- - - - - -\n\nSUICIDAL MONITOR:\n\n%1 (%2), %3 and %4.\n\nAction range = %5m.\n\nRelease the trigger range = %6m.\n\n- - - - - -\n\nTARGET MONITOR:\n\nWho's the enemy = %7.\n\nEnemy target is = %8\n(0=any / 1=playables / 2=onlyPlayers / 3=specialOne).\n\nNearest target = %9.\n\n- - - - - -\n\nVEST MONITOR:\n\nActivation = %10.\n\nDetonated = %11.\n\n", lifeState _suicidal, (1 - damage _suicidal)*100, behaviour _suicidal, combatMode _suicidal, _dmtActRange, _dmtDeadRange, _suicidalEnemy, _suicidalTargets, _targetNearest, _isDmtVestActivated, _dmtVestDetonated];
	};	
	
	if (alive _suicidal) then     // if the suicidal is alive, so...
	{
		//removeGoggles _suicidal;     // removes any cosmetic from the suicidal's face.
		//removeHeadgear _suicidal;     // removes any cosmetic from the suicidal head.
		//removeAllAssignedItems _suicidal;     // Unassigns and deletes all linked items from inventory.
		//removeAllContainers _suicidal;     // removes backpack, vest and uniform.
			removeBackpack _suicidal;     // remove the backpack.
			removeVest _suicidal;     // remove the wrong vest.
			//removeUniform _suicidal;     // remove the uniform.
		
		_suicidal addVest _dmtVestIed;     // add the correct suicidal vest.
		_suicidal allowFleeing 0;     // suicidal is NOT panic.
		
		if (_suicidalTargets != 3) then     // if the suicidal focus is NOT just one special target, so...
		{
			_threatPos = getPosATL _suicidal;     // takes the current suicidal position. 
			
			if (_suicidalTargets == 2) then     // if the suicidal consider only enemy players as potential targets.
			{
				// pick up the dist from each enemy alive to suicidal and load the array with the distances: 
				_targetDistance = (allPlayers select {alive _x}) apply {[_x distanceSqr _threatPos, _x]}; 	
			};
			
			if (_suicidalTargets == 1) then     // if the suicidal consider enemy players and playable units as potential targets.
			{
				// Warning: if your mission has AI disable and _suicidalTargets is = 1, you'll face an error.
				_targetDistance = (playableUnits select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			if (_suicidalTargets == 0) then     // if the suicidal consider all enemy units (player, playable unit, regular unit) as potential targets.
			{
				// PERFORMANCE KILLER WHEN TOO MUCH TARGETS
				_targetDistance = ((units _suicidalEnemy) select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			_targetDistance sort true;     // sort the distances in array from smallest to biggest. 
			_targetNearest = _targetDistance #0#1;     // the closest target (player, for example) is in the _targetDistance array first position.
		
		} else     // if the suicidal focus finally is just one special target, do...
		{
			_targetNearest = _specialTarget;     // the nearest target is the only one: _specialTarget.
			sleep 2;     // execution breath.
		};
		
		//(THERE'S A BUG WITH ACE, WIP)
		if ((_isDmtVestActivated == false) and ((damage _suicidal) >= 0.1)) then     // if the suicidal vest isn't activated and the suicidal gets hurt, so... 
		{	
			sleep 0.5;     // waits a while before next action.
			_isDmtVestActivated = true;     // suicidal actives the vest.
		};
		
		if (_suicidal getVariable ["ace_captives_isHandcuffed", false]) then     // if the suicidal is handcuffed, then...
		{
			_isSuicidalCuffed = true;     // understand that suicidal is handcuffed.
			_isDmtVestActivated = false;     // vest disabled.
			removeGoggles _suicidal;     // removes any cosmetic from the suicidal's face.
			removeHeadgear _suicidal;     // removes any cosmetic from the suicidal head.
			//removeAllAssignedItems _suicidal;     // Unassigns and deletes all linked items from inventory.
			removeAllContainers _suicidal;     // removes backpack, vest and uniform.
				//removeBackpack _suicidal;     // remove the backpack.
				//removeVest _suicidal;     // remove the vest.
				//removeUniform _suicidal;     // remove the uniform.
					
			_suicidal addGoggles "G_Blindfold_01_white_F";     // adds a blindfold over the suicidal's eyes;
		};
		
		// ACTION RANGE
		if ((!isNull _targetNearest) and ((_targetNearest distance _suicidal) <= _dmtActRange)) then     // if there's a target and it's inside the suicidal action range, so...
		{						
			_isDmtVestActivated = true;     // suicidal trigger activates the detonator and presses the trigger (which will detonate if he lets go).
			_suicidal setBehaviour "CARELESS";     // suicidal no longer cares about their own safety.
			_suicidal setCombatMode "RED";     // suicida fire at will, engage at will/loose formation.
			
			if ((lifeState _suicidal != "HEALTHY") and (_isDmtVestActivated == true)) then     // if suicidal becomes unconscious or incapacitated, and the vest is activated, so...
			{
				_suicidal directSay "";     // shut up.
				sleep (3 + random 4);     // wait from X to Y seconds before...
				_dmtVestIedAmmo createVehicle getPos _suicidal;     // a bomb is created at the suicidal's position, boom!
				_dmtVestDetonated = true;     // sets the suicidal vest as detonated.
				deletevehicle _suicidal;     // the suicidal is deleted (dead or not).
				sleep 0.1;     // execution breath.
				_suicidalMethod != 2;     // Stoping the While/loop of this method.
			};
			
			if (!isNull objectParent _suicidal) then     // if the suicidal is inside a vehicle, then...
			{					
				_suicidal leaveVehicle objectParent _suicidal;     // suicidal dismount;
			};
			
			_suicidal setSpeedMode "FULL";     // suicidal moves at full speed...
			_suicidal move getPos _targetNearest;     // up the player.
			
			if ((_suicidal distance _targetNearest) <= (_dmtDeadRange + 8)) then     // if player is almost at _dmtDeadRange (plus a few meters of margin), then...
			{
				_suicidal directSay _deathShout;     // suicidal screams.
			};

			// DEAD RANGE			
			if ((_suicidal distance _targetNearest) <= _dmtDeadRange) then     // if distance between suicidal and player is less than or equal to XXm, then...
			{	
				if ((_isSuicidalCuffed == false) and (_dmtVestDetonated == false)) then     // if the suicidal isn't cuffed and the vest hasn't already blew up, then...
				{
					sleep 0.3;     // waits a while before the next action.
					_dmtVestIedAmmo createVehicle getPos _suicidal;     // a bomb is created at the suicidal's position, boom!
					_dmtVestDetonated = true;     // sets the suicidal vest as detonated.
					deletevehicle _suicidal;     // the suicidal is deleted (dead or not).
					sleep 0.1;     // execution breath.
					_suicidalMethod != 2;     // Stoping the While/loop of this method.
				};
			};
		};
		
	} else     // if the suicidal is NOT alive, do...
	{
		if ((_isDmtVestActivated == true) and (_dmtVestDetonated == false)) then     // if the vest's detonator is activated, and if the vest hasn't already detonated, then...
		{
			sleep (1 + random 4);     // waits a split second before the next action.
			_dmtVestIedAmmo createVehicle getPos _suicidal;     // a bomb is created at the suicidal's position, boom!
			_dmtVestDetonated = true;     // sets the suicidal vest as detonated.
			deletevehicle _suicidal;     // the suicidal is deleted (dead or not).
			sleep 0.1;     // execution breath.
			_suicidalMethod != 2;     // Stoping the While/loop of this method.
		};
	};
	
	sleep 1;     // breath of execution.
};
	
	
	
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
/* 

	3) CLASSIC SUICIDE BOMBER (Press-trigger)
	
*/
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


While {_suicidalMethod == 3} do     // Looping while: se doctrine method is classic suicide bomber, do it:
{
	if (_debugMonitor == true) then     // if debug on, so...
	{
		// show info on screen:
		hint format ["\n\nSUICIDE BOMBER METHOD\n\n- - - - - -\n\nSUICIDAL MONITOR:\n\n%1 (%2), %3 and %4.\n\nAction range = %5m.\n\nPush the trigger range = %6m.\n\n- - - - - -\n\nTARGET MONITOR:\n\nWho's the enemy = %7.\n\nEnemy target is = %8\n(0=any / 1=playables / 2=onlyPlayers / 3=specialOne).\n\nNearest target = %9.\n\n- - - - - -\n\nVEST MONITOR:\n\nDetonated = %10.\n\n", lifeState _suicidal, (1 - damage _suicidal)*100, behaviour _suicidal, combatMode _suicidal, _csbActRange, _csbDeadRange, _suicidalEnemy, _suicidalTargets, _targetNearest, _csbVestDetonated];
	};	
	
	if (alive _suicidal) then     // if the suicidal is alive, so...
	{
		//removeGoggles _suicidal;     // removes any cosmetic from the suicidal's face.
		//removeHeadgear _suicidal;     // removes any cosmetic from the suicidal head.
		//removeAllAssignedItems _suicidal;     // Unassigns and deletes all linked items from inventory.
		//removeAllContainers _suicidal;     // removes backpack, vest and uniform.
			removeBackpack _suicidal;     // remove the backpack.
			removeVest _suicidal;     // remove the wrong vest.
			//removeUniform _suicidal;     // remove the uniform.
		
		_suicidal addVest _csbVestIed;     // add the correct suicidal vest.
		_suicidal allowFleeing 0;     // suicidal is NOT panic.
		
		if (_suicidalTargets != 3) then     // if the suicidal focus is NOT just one special target, so...
		{
			_threatPos = getPosATL _suicidal;     // takes the current suicidal position. 
			
			if (_suicidalTargets == 2) then     // if the suicidal consider only enemy players as potential targets.
			{
				// pick up the dist from each enemy alive to suicidal and load the array with the distances: 
				_targetDistance = (allPlayers select {alive _x}) apply {[_x distanceSqr _threatPos, _x]}; 	
			};
			
			if (_suicidalTargets == 1) then     // if the suicidal consider enemy players and playable units as potential targets.
			{
				// Warning: if your mission has AI disable and _suicidalTargets is = 1, you'll face an error.
				_targetDistance = (playableUnits select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			if (_suicidalTargets == 0) then     // if the suicidal consider all enemy units (player, playable unit, regular unit) as potential targets.
			{
				// PERFORMANCE KILLER WHEN TOO MUCH TARGETS
				_targetDistance = ((units _suicidalEnemy) select {alive _x}) apply {[_x distanceSqr _threatPos,_x]}; 
			};
			
			_targetDistance sort true;     // sort the distances in array from smallest to biggest. 
			_targetNearest = _targetDistance #0#1;     // the closest target (player, for example) is in the _targetDistance array first position.
		
		} else     // if the suicidal focus finally is just one special target, do...
		{
			_targetNearest = _specialTarget;     // the nearest target is the only one: _specialTarget.
			sleep 2;     // execution breath.
		};
			
		if (_suicidal getVariable ["ace_captives_isHandcuffed", false]) then     // if the suicidal is handcuffed, then...
		{
			_isSuicidalCuffed = true;     // understand that suicidal is handcuffed.
			removeGoggles _suicidal;     // removes any cosmetic from the suicidal's face.
			removeHeadgear _suicidal;     // removes any cosmetic from the suicidal head.
			//removeAllAssignedItems _suicidal;     // Unassigns and deletes all linked items from inventory.
			removeAllContainers _suicidal;     // removes backpack, vest and uniform.
				//removeBackpack _suicidal;     // remove the backpack.
				//removeVest _suicidal;     // remove the vest.
				//removeUniform _suicidal;     // remove the uniform.
					
			_suicidal addGoggles "G_Blindfold_01_white_F";     // adds a blindfold over the suicidal's eyes;
		};
		
		// ACTION RANGE
		if ((!isNull _targetNearest) and ((_targetNearest distance _suicidal) <= _csbActRange)) then     // if there's a target and it's inside the suicidal action range, so...
		{						
			_suicidal setBehaviour "CARELESS";     // suicidal no longer cares about their own safety.
			_suicidal setCombatMode "RED";     // suicidal fire at will, engage at will/loose formation.
			
			if (lifeState _suicidal != "HEALTHY") then     // if suicidal becomes unconscious or incapacitated, so...
			{
					_suicidal directSay "";     // shut up.
			};
			
			if (!isNull objectParent _suicidal) then     // if the suicidal is inside a vehicle, then...
			{					
				_suicidal leaveVehicle objectParent _suicidal;     // suicidal dismount;
			};
			
			_suicidal setSpeedMode "FULL";     // suicidal moves at full speed...
			_suicidal move getPos _targetNearest;     // up the player.
			
			if ((_suicidal distance _targetNearest) <= (_csbDeadRange + 8)) then     // if player is almost at _csbDeadRange (plus a few meters of margin), then...
			{
				_suicidal directSay _deathShout;     // suicidal screams.
			};

			// DEAD RANGE			
			if ((_suicidal distance _targetNearest) <= _csbDeadRange) then     // if distance between suicidal and player is less than or equal to XXm, then...
			{	
				// if the suicidal isn't incapacitaded, isn't cuffed, and the vest hasn't already blew up:
				if ((lifeState _suicidal == "HEALTHY") and (_isSuicidalCuffed == false) and (_csbVestDetonated == false)) then     // so...
				{
					sleep 0.3;     // waits a while before the next action.
					_csbVestIedAmmo createVehicle getPos _suicidal;     // a bomb is created at the suicidal's position, boom!
					_csbVestDetonated = true;     // sets the suicidal vest as detonated.
					deletevehicle _suicidal;     // the suicidal is deleted (dead or not).
					sleep 0.1;     // execution breath.
					_suicidalMethod != 3;     // Stoping the While/loop of this method.
				};
			};
		};	
	};
	
	sleep 1;     // breath of execution.
};