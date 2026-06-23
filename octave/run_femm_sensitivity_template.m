% FEMM sensitivity analysis template for GNU Octave.
%
% This script assumes you already have a baseline .fem model and want to
% sweep a few parameters automatically. Adapt the circuit name, group IDs,
% labels, and result extraction logic to your own FEMM model.

clear;
clc;

% ----------------------------
% User configuration
% ----------------------------
base_model_path = fullfile("models", "actuator_base.fem");
working_model_path = fullfile("models", "actuator_working_copy.fem");
output_csv_path = fullfile("results", "sensitivity_results.csv");

% Replace with the actual circuit name used inside your FEMM model.
circuit_name = "coil";

% Example sweep: current and air gap.
currents_a = [1.0, 2.0, 3.0, 4.0];
air_gaps_mm = [0.5, 1.0, 1.5];

cases = build_cases(currents_a, air_gaps_mm);
results = zeros(rows(cases), 6);

ensure_parent_directory(output_csv_path);

openfemm();

for idx = 1:rows(cases)
  current_a = cases(idx, 1);
  air_gap_mm = cases(idx, 2);

  opendocument(base_model_path);
  mi_saveas(working_model_path);

  apply_case_to_model(current_a, air_gap_mm, circuit_name);

  mi_analyze();
  mi_loadsolution();

  case_result = extract_case_result(current_a, air_gap_mm, circuit_name);
  results(idx, :) = [idx, current_a, air_gap_mm, case_result];

  mo_close();
  mi_close();
endfor

closefemm();

write_results_csv(output_csv_path, results);

disp("Sensitivity sweep complete.");
disp(["Results written to: ", output_csv_path]);


function cases = build_cases(currents_a, air_gaps_mm)
  case_count = numel(currents_a) * numel(air_gaps_mm);
  cases = zeros(case_count, 2);
  row_idx = 1;

  for i = 1:numel(currents_a)
    for j = 1:numel(air_gaps_mm)
      cases(row_idx, :) = [currents_a(i), air_gaps_mm(j)];
      row_idx = row_idx + 1;
    endfor
  endfor
endfunction


function apply_case_to_model(current_a, air_gap_mm, circuit_name)
  % Update the current excitation.
  mi_modifycircprop(circuit_name, 1, current_a);

  % Geometry editing is model-specific. Replace this example with the
  % node, segment, block-label, or group operations that match your model.
  %
  % Example approaches:
  % - move a selected group with mi_movetranslate
  % - update dimensions by selecting nodes and moving them
  % - switch materials with mi_setblockprop
  %
  % The block below is only a placeholder to show where air-gap updates go.
  if air_gap_mm < 0
    error("air_gap_mm must be non-negative");
  endif

  % Example placeholder:
  % group_id = 2;
  % mi_selectgroup(group_id);
  % mi_movetranslate(0, air_gap_mm - baseline_gap_mm);
  % mi_clearselected();
endfunction


function case_result = extract_case_result(current_a, air_gap_mm, circuit_name)
  circuit_data = mo_getcircuitproperties(circuit_name);

  circuit_current = circuit_data(1);
  flux_or_voltage_term = circuit_data(3);

  % Example derived metric. Replace with inductance, force, torque, etc.
  if abs(current_a) > 0
    normalized_response = flux_or_voltage_term / current_a;
  else
    normalized_response = 0;
  endif

  case_result = [circuit_current, flux_or_voltage_term, ...
                 normalized_response];
endfunction


function write_results_csv(output_csv_path, results)
  fid = fopen(output_csv_path, "w");
  if fid < 0
    error("Failed to open output CSV: %s", output_csv_path);
  endif

  fprintf(fid, "case_index,current_a,air_gap_mm,circuit_current,flux_or_voltage_term,normalized_response\n");

  for idx = 1:rows(results)
    fprintf(fid, "%.0f,%.6f,%.6f,%.6f,%.6f,%.6f\n", results(idx, :));
  endfor

  fclose(fid);
endfunction


function ensure_parent_directory(file_path)
  [parent_dir, ~, ~] = fileparts(file_path);
  if ~isempty(parent_dir) && exist(parent_dir, "dir") ~= 7
    mkdir(parent_dir);
  endif
endfunction
