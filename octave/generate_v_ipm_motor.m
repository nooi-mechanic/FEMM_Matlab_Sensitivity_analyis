%% ========================= FEMM V-IPM Modeling ==========================
clc, clear

% Material definitions
PM = 'SmCo17_Grade17';
Core = 'SiSteel';
Coil = '18 AWG';
Coilname = {'Coil_A','Coil_B','Coil_C'};

% Geometry parameters from the provided specification (mm)
stack_length = 110;
stator_outer_radius = 300 / 2;
rotor_outer_radius = 154 / 2;
airgap_length = 1.0;
stator_inner_radius = rotor_outer_radius + airgap_length;

shaft_radius = 28;
turns = 40;
max_segment = 10;

% 4-pole / 3-slot stator parameters
num_slots = 3;
slot_pitch_deg = 360 / num_slots;
tooth_arc_deg = 55;
slot_arc_deg = slot_pitch_deg - tooth_arc_deg;
slot_depth = 32;
slot_outer_radius = stator_inner_radius + slot_depth;
slot_label_radius = stator_inner_radius + slot_depth * 0.55;

% V-shaped IPM rotor parameters
magnet_length = 26;
magnet_thickness = 8;
v_angle_deg = 28;
magnet_center_radius = rotor_outer_radius - 18;
magnet_center_offset_deg = 10;

% Output folder
output_dir = fullfile(pwd, 'femm_output_v_ipm');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% FEMM setting
openfemm(1);
newdocument(0);
mi_probdef(0,'millimeters','planar',1E-8,stack_length,30,0);

% Core material
mi_addmaterial(Core, 4000, 4000, 0, 1.8e6, 0.0, 0.35, 1.5, 0.95, 0, 0, 0, 0, 0);
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
    mi_addbhpoint(Core, core_bh(idx,2), core_bh(idx,1));
end

% Magnet material
mi_addmaterial(PM, 1.0, 1.05, 0, -750e3, 6.7e5);
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
    mi_addbhpoint(PM, pm_bh(idx,2), pm_bh(idx,1));
end

% Get materials
mi_getmaterial('Air');
mi_getmaterial(Coil);

% Rotor outer boundary
mi_drawarc(rotor_outer_radius,0,-rotor_outer_radius,0,180,max_segment);
mi_addarc(-rotor_outer_radius,0,rotor_outer_radius,0,180,max_segment);

% Shaft opening
mi_drawarc(shaft_radius,0,-shaft_radius,0,180,max_segment);
mi_addarc(-shaft_radius,0,shaft_radius,0,180,max_segment);

% V-type magnet cavities and labels
magnet_specs = [
  90 + magnet_center_offset_deg,  magnet_center_radius,  90 + v_angle_deg,  90 + v_angle_deg;
  90 - magnet_center_offset_deg,  magnet_center_radius,  90 - v_angle_deg,  90 - v_angle_deg;
  270 - magnet_center_offset_deg, magnet_center_radius, 270 - v_angle_deg, 270 - v_angle_deg;
  270 + magnet_center_offset_deg, magnet_center_radius, 270 + v_angle_deg, 270 + v_angle_deg
];

for magnet_idx = 1:size(magnet_specs,1)
    center_angle_deg = magnet_specs(magnet_idx,1);
    center_radius = magnet_specs(magnet_idx,2);
    body_angle_deg = magnet_specs(magnet_idx,3);
    magnetization_deg = magnet_specs(magnet_idx,4);

    angle_rad = deg2rad(center_angle_deg);
    body_rad = deg2rad(body_angle_deg);

    center_x = center_radius * cos(angle_rad);
    center_y = center_radius * sin(angle_rad);

    along_x = cos(body_rad);
    along_y = sin(body_rad);
    normal_x = -sin(body_rad);
    normal_y = cos(body_rad);

    half_length = magnet_length / 2;
    half_thickness = magnet_thickness / 2;

    p1x = center_x + along_x * half_length + normal_x * half_thickness;
    p1y = center_y + along_y * half_length + normal_y * half_thickness;
    p2x = center_x + along_x * half_length - normal_x * half_thickness;
    p2y = center_y + along_y * half_length - normal_y * half_thickness;
    p3x = center_x - along_x * half_length - normal_x * half_thickness;
    p3y = center_y - along_y * half_length - normal_y * half_thickness;
    p4x = center_x - along_x * half_length + normal_x * half_thickness;
    p4y = center_y - along_y * half_length + normal_y * half_thickness;

    mi_drawline(p1x,p1y,p2x,p2y);
    mi_drawline(p2x,p2y,p3x,p3y);
    mi_drawline(p3x,p3y,p4x,p4y);
    mi_drawline(p4x,p4y,p1x,p1y);

    mi_addblocklabel(center_x,center_y);
    mi_selectlabel(center_x,center_y);
    mi_setblockprop(PM,1,0,0,magnetization_deg,1,0);
    mi_clearselected;
end

% Rotor steel and shaft labels
mi_addblocklabel(0,shaft_radius + 8);
mi_selectlabel(0,shaft_radius + 8);
mi_setblockprop(Core,1,0,0,0,1,0);
mi_clearselected;

mi_addblocklabel(0,0);
mi_selectlabel(0,0);
mi_setblockprop('Air',1,0,0,0,1,0);
mi_clearselected;

% Stator outer boundary
mi_drawarc(stator_outer_radius,0,-stator_outer_radius,0,180,max_segment);
mi_addarc(-stator_outer_radius,0,stator_outer_radius,0,180,max_segment);

% 4p3s stator: draw 3 slot windows directly to avoid broken self-intersections.
for slot_idx = 0:(num_slots - 1)
    slot_center_deg = slot_idx * slot_pitch_deg;
    slot_start_deg = slot_center_deg - slot_arc_deg / 2;
    slot_end_deg = slot_center_deg + slot_arc_deg / 2;
    tooth_start_deg = slot_end_deg;
    tooth_end_deg = slot_start_deg + slot_pitch_deg;

    slot_start_rad = deg2rad(slot_start_deg);
    slot_end_rad = deg2rad(slot_end_deg);
    tooth_start_rad = deg2rad(tooth_start_deg);
    tooth_end_rad = deg2rad(tooth_end_deg);

    slot_inner_start_x = stator_inner_radius * cos(slot_start_rad);
    slot_inner_start_y = stator_inner_radius * sin(slot_start_rad);
    slot_inner_end_x = stator_inner_radius * cos(slot_end_rad);
    slot_inner_end_y = stator_inner_radius * sin(slot_end_rad);
    slot_outer_start_x = slot_outer_radius * cos(slot_start_rad);
    slot_outer_start_y = slot_outer_radius * sin(slot_start_rad);
    slot_outer_end_x = slot_outer_radius * cos(slot_end_rad);
    slot_outer_end_y = slot_outer_radius * sin(slot_end_rad);

    mi_drawline(slot_inner_start_x,slot_inner_start_y,slot_outer_start_x,slot_outer_start_y);
    mi_drawline(slot_inner_end_x,slot_inner_end_y,slot_outer_end_x,slot_outer_end_y);
    mi_drawarc(slot_outer_start_x,slot_outer_start_y,slot_outer_end_x,slot_outer_end_y,slot_arc_deg,max_segment);

    tooth_start_x = stator_inner_radius * cos(tooth_start_rad);
    tooth_start_y = stator_inner_radius * sin(tooth_start_rad);
    tooth_end_x = stator_inner_radius * cos(tooth_end_rad);
    tooth_end_y = stator_inner_radius * sin(tooth_end_rad);
    mi_drawarc(tooth_start_x,tooth_start_y,tooth_end_x,tooth_end_y,tooth_arc_deg,max_segment);

    slot_label_angle = deg2rad(slot_center_deg);
    slot_label_x = slot_label_radius * cos(slot_label_angle);
    slot_label_y = slot_label_radius * sin(slot_label_angle);
    mi_addblocklabel(slot_label_x,slot_label_y);
    mi_selectlabel(slot_label_x,slot_label_y);
    mi_setblockprop(Coil,1,0,Coilname{slot_idx + 1},0,2,turns);
    mi_clearselected;
end

% Stator and air labels
mi_addblocklabel(stator_outer_radius - 2,0);
mi_selectlabel(stator_outer_radius - 2,0);
mi_setblockprop(Core,1,0,0,0,2,0);
mi_clearselected;

mi_addblocklabel((rotor_outer_radius + stator_inner_radius)/2,0);
mi_selectlabel((rotor_outer_radius + stator_inner_radius)/2,0);
mi_setblockprop('Air',1,0,0,0,2,0);
mi_clearselected;

mi_addblocklabel(stator_outer_radius + 10,0);
mi_selectlabel(stator_outer_radius + 10,0);
mi_setblockprop('Air',1,0,0,0,2,0);
mi_clearselected;

% Commutation-ready circuit properties for A/B/C phases.
for phase_idx = 1:numel(Coilname)
    mi_addcircprop(Coilname{phase_idx},0,1);
end

% Boundary and save
mi_makeABC(7,stator_outer_radius * 1.2,0,0,0);
filename = fullfile(output_dir, 'v_ipm_motor_4p3s.fem');
mi_saveas(filename);

% This file currently generates geometry only.
