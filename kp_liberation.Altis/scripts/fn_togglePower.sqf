/*
  fn_togglePower.sqf
  Called via addAction when you flip a switch.
  Params:
    _switch = the switch object
    _marker = marker name for the town
    _xfmr   = transformer object
    _label  = friendly town name
    _radius = search radius (in metres)
*/
params ["_switch","_marker","_xfmr","_label","_radius"];

private _lights  = nearestObjects [markerPos _marker, ["Lamp_F"], _radius];
private _turnOn  = switchPosition _switch > 0.5;

if (_turnOn) then {
    if (alive _xfmr) then {
        { _x switchDir "On"; } forEach _lights;
    } else {
        _switch switchDir "Off";
        hint format ["⚠ Power to %1 is offline (transformer destroyed)", _label];
    };
} else {
    { _x switchDir "Off"; } forEach _lights;
};