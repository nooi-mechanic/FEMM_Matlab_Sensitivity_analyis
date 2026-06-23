%% generate_spm_motor.m - FEMM SPM motor model generation

openfemm(1);
newdocument(0);

depth = 150;
mi_probdef(0, "millimeters", "planar", 1.0e-8, depth, 30, 0);

% Material definitions used by this model.
pm_material = "SmCo17_Grade17";
core_material = "SiSteel";
sealing_material = "Inconel 718";
coil_material = "18 AWG";
coil_names = {"Coil_A", "Coil_B", "Coil_C"};

mi_addmaterial(core_material, 4000, 4000, 0, 1.8e6, 0.0, 0.35, 1.5, 0.95, 0, 0, 0, 0, 0);

core_bh = [
  0,     0.000;
  100,   0.005;
  500,   0.050;
  1000,  0.150;
  2000,  0.300;
  3000,  0.450;
  5000,  0.700;
  8000,  1.000;
  12000, 1.250;
  16000, 1.400;
  20000, 1.450;
  25000, 1.470;
  30000, 1.480;
  35000, 1.490;
  40000, 1.500
];

for idx = 1:size(core_bh, 1)
  mi_addbhpoint(core_material, core_bh(idx, 2), core_bh(idx, 1));
end

mi_addmaterial(pm_material, 1.0, 1.05, 0, -750e3, 6.7e5);

pm_bh = [
  0,       0.00;
  20e3,    0.10;
  100e3,   0.30;
  300e3,   0.60;
  500e3,   0.78;
  650e3,   0.87;
  750e3,   0.95;
  850e3,   1.00;
  950e3,   1.03;
  1100e3,  1.05;
  1300e3,  1.07;
  1500e3,  1.08
];

for idx = 1:size(pm_bh, 1)
  mi_addbhpoint(pm_material, pm_bh(idx, 2), pm_bh(idx, 1));
end

mi_addmaterial(sealing_material, ...
  1.02, ...
  1.02, ...
  0, ...
  0, ...
  0.8, ...
  0, ...
  0, ...
  1, ...
  0, ...
  0, ...
  0, ...
  1, ...
  0);

% Load library materials used directly by name.
mi_getmaterial("Air");
mi_getmaterial(coil_material);

% Geometry parameters.
pm_radius = 53 / 2;
seal_thickness = 5;
stator_inner_radius = 64 / 2;
stator_outer_radius = 150 / 2;
slot_length = 20;
turns = 200;
max_segment = 10;
slot_pitch_deg = 5;
num_slots = 36;
tooth_half_angle = pi / 66.95;
tooth_length_inner = 1;
tooth_length_outer = 1;
arc_offset = 0.01 * pi;

tooth_tip_radius = stator_inner_radius + tooth_length_inner;
tooth_shoulder_radius = tooth_tip_radius + tooth_length_outer;
slot_outer_radius = tooth_shoulder_radius + slot_length;

% Rotor arcs.
mi_drawarc(pm_radius, 0, -pm_radius, 0, 180, max_segment);
mi_selectarcsegment(0, pm_radius);
mi_setarcsegmentprop(max_segment, "None", 0, 1);
mi_clearselected();

mi_addarc(-pm_radius, 0, pm_radius, 0, 180, max_segment);
mi_selectarcsegment(0, -pm_radius);
mi_setarcsegmentprop(max_segment, "None", 0, 1);
mi_clearselected();

outer_pm_radius = pm_radius + seal_thickness;
mi_drawarc(outer_pm_radius, 0, -outer_pm_radius, 0, 180, max_segment);
mi_selectarcsegment(0, pm_radius + seal_thickness / 2);
mi_setarcsegmentprop(max_segment, "None", 0, 1);
mi_clearselected();

mi_drawarc(-outer_pm_radius, 0, outer_pm_radius, 0, 180, max_segment);
mi_selectarcsegment(0, -pm_radius - seal_thickness / 2);
mi_setarcsegmentprop(max_segment, "None", 0, 1);
mi_clearselected();

% Rotor and seal labels.
mi_addblocklabel(0, 0);
mi_selectlabel(0, 0);
mi_setblockprop(pm_material, 1, 0, 0, 90, 1, 0);
mi_clearselected();

mi_addblocklabel(0, pm_radius + seal_thickness / 2);
mi_selectlabel(0, pm_radius + seal_thickness / 2);
mi_setblockprop(sealing_material, 1, 0, 0, 90, 1, 0);
mi_clearselected();

% Stator outer boundary.
mi_drawarc(stator_outer_radius, 0, -stator_outer_radius, 0, 180, max_segment);
mi_addarc(-stator_outer_radius, 0, stator_outer_radius, 0, 180, max_segment);

% Teeth and slot opening geometry.
for slot_idx = 0:(num_slots - 1)
  prev_angle = deg2rad((slot_idx - 1) * slot_pitch_deg);
  curr_angle = deg2rad(slot_idx * slot_pitch_deg);
  next_angle = deg2rad((slot_idx + 1) * slot_pitch_deg);
  next_next_angle = deg2rad((slot_idx + 2) * slot_pitch_deg);

  if mod(slot_idx, 2) == 1
    p1 = polar_point(stator_inner_radius, prev_angle - tooth_half_angle);
    p2 = polar_point(stator_inner_radius, curr_angle + tooth_half_angle);
    p3 = polar_point(tooth_tip_radius, prev_angle - tooth_half_angle);
    p4 = polar_point(tooth_tip_radius, curr_angle + tooth_half_angle);
    p5 = polar_point(tooth_shoulder_radius, prev_angle);
    p6 = polar_point(tooth_shoulder_radius, curr_angle);
    p7 = polar_point(slot_outer_radius, curr_angle - arc_offset);

    mi_drawarc(p1(1), p1(2), p2(1), p2(2), slot_pitch_deg + rad2deg(2 * tooth_half_angle), max_segment);
    mi_drawline(p1(1), p1(2), p3(1), p3(2));
    mi_drawline(p2(1), p2(2), p4(1), p4(2));
    mi_drawline(p3(1), p3(2), p5(1), p5(2));
    mi_drawline(p4(1), p4(2), p6(1), p6(2));
    mi_drawline(p6(1), p6(2), p7(1), p7(2));
  else
    p1 = polar_point(slot_outer_radius, next_angle - arc_offset);
    p2 = polar_point(slot_outer_radius, next_next_angle + arc_offset);
    p3 = polar_point(stator_inner_radius, prev_angle + tooth_half_angle);
    p4 = polar_point(stator_inner_radius, curr_angle - tooth_half_angle);
    p5 = polar_point(tooth_shoulder_radius, curr_angle);
    p6 = polar_point(slot_outer_radius, curr_angle + arc_offset);

    mi_drawarc(p1(1), p1(2), p2(1), p2(2), 180, max_segment);
    mi_drawarc(p3(1), p3(2), p4(1), p4(2), slot_pitch_deg - rad2deg(2 * tooth_half_angle), max_segment);
    mi_drawline(p5(1), p5(2), p6(1), p6(2));
  endif
endfor

% Stator and air labels.
mi_addblocklabel(stator_outer_radius - 0.1, 0);
mi_selectlabel(stator_outer_radius - 0.1, 0);
mi_setblockprop(core_material, 1, 0, 0, 0, 2, 0);
mi_clearselected();

mi_addblocklabel((outer_pm_radius + stator_inner_radius) / 2, 0);
mi_selectlabel((outer_pm_radius + stator_inner_radius) / 2, 0);
mi_setblockprop("Air", 1, 0, 0, 0, 2, 0);
mi_clearselected();

mi_addblocklabel(pm_radius * 5, 0);
mi_selectlabel(pm_radius * 5, 0);
mi_setblockprop("Air", 1, 0, 0, 0, 2, 0);
mi_clearselected();

% Distributed winding labels.
coil_radius = slot_outer_radius;
coil_phase_offsets = [-pi / 3, 0, pi / 3, 2 * pi / 3, pi, 4 * pi / 3];
coil_phase_names = {coil_names{3}, coil_names{1}, coil_names{2}, ...
                    coil_names{3}, coil_names{1}, coil_names{2}};
coil_turn_signs = [-1, 1, 1, 1, -1, -1];

for phase_idx = 1:numel(coil_names)
  mi_addcircprop(coil_names{phase_idx}, 0, 1);
endfor

for sector_idx = 1:3
  base_left_angle = deg2rad((2 * sector_idx - 1) * slot_pitch_deg);
  base_right_angle = deg2rad((2 * sector_idx + 1) * slot_pitch_deg);

  for coil_idx = 1:numel(coil_phase_offsets)
    label_point = average_points( ...
      polar_point(coil_radius, base_left_angle + coil_phase_offsets(coil_idx)), ...
      polar_point(coil_radius, base_right_angle + coil_phase_offsets(coil_idx)));

    mi_addblocklabel(label_point(1), label_point(2));
    mi_selectlabel(label_point(1), label_point(2));
    mi_setblockprop(coil_material, 1, 0, coil_phase_names{coil_idx}, 0, 2, coil_turn_signs(coil_idx) * turns);
    mi_clearselected();
  endfor
endfor

mi_makeABC(7, pm_radius * 20, 0, 0, 0);
mi_saveas("spm.fem");
closefemm();


function point = polar_point(radius, angle_rad)
  point = [radius * cos(angle_rad), radius * sin(angle_rad)];
endfunction


function midpoint = average_points(point_a, point_b)
  midpoint = (point_a + point_b) / 2;
endfunction
