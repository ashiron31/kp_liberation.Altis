/*
  fn_transformerTrip.sqf
  Killed EH for transformer – instant trip.
  _this params: [ destroyedUnit, killer, projectile ]
*/
params ["_unit","_killer","_proj"];

// grab the switch & label we stored
private _switch = _unit getVariable ["mySwitch", nil];
private _label  = _unit getVariable ["townLabel", "Unknown"];

if (isTouchingTerrain _unit and !isNil {_switch} and alive _switch) then {
    _switch switchDir "Off";
    hint format ["💥 Transformer down – power to %1 has tripped!", _label];
};