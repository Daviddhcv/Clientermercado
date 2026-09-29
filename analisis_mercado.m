% =========================================================================
% SCRIPT DE MATLAB CORREGIDO: Análisis Estadístico y Simulación Monte Carlo
% Base de Datos: Encuesta a Clientes Mercado Municipal "Sauces 9" (N = 438)
% =========================================================================

clear; clc; close all;

%% PASO 1: Carga directa de la base de datos desde el archivo Excel
filename = 'Encuesta a Clientes MERCADO SAUCES 9(1-438).xlsx';

% Lectura universal compatible con cualquier versión de MATLAB
data = readtable(filename, 'FileType', 'spreadsheet');

% Desplegar dimensiones iniciales del conjunto de datos analizado
fprintf('Dimensiones de la base de datos cargada: %d filas x %d columnas\n\n', size(data, 1), size(data, 2));

%% PASO 2: Análisis Demográfico y Frecuencias Categóricas
% Extracción de variables demográficas y de comportamiento
genero = data{:, 8};         % Columna de Género
edad_grupo = data{:, 7};     % Columna de Rango de Edad
frecuencia_visita = data{:, 9}; % Columna de Frecuencia de Visita

% Cálculo de frecuencias y porcentajes para el Género
[cat_genero, ~, ic_genero] = unique(genero);
freq_genero = accumarray(ic_genero, 1);
pct_genero = (freq_genero / length(genero)) * 100;

disp('--- 1. DISTRIBUCIÓN SOCIODEMOGRÁFICA POR GÉNERO ---');
for i = 1:length(cat_genero)
    fprintf('   -> %s: %d encuestados (%.2f%%)\n', string(cat_genero(i)), freq_genero(i), pct_genero(i));
end
fprintf('\n');

%% PASO 3: Análisis del Net Promoter Score (NPS) y Simulación Monte Carlo
% Extracción de la columna NPS (Escala de 0 a 10)
nps_raw = str2double(string(data{:, 14}));
nps_raw = nps_raw(~isnan(nps_raw));

% Clasificación estricta: Promotores (9-10), Pasivos (7-8), Detractores (0-6)
promotores = sum(nps_raw >= 9);
pasivos = sum(nps_raw >= 7 & nps_raw <= 8);
detractores = sum(nps_raw <= 6);
total_nps = length(nps_raw);

pct_prom = (promotores / total_nps) * 100;
pct_pas = (pasivos / total_nps) * 100;
pct_det = (detractores / total_nps) * 100;
nps_index = pct_prom - pct_det;

fprintf('--- 2. MÉTRICAS DE LEALTAD Y RECOMENDACIÓN (NPS) ---\n');
fprintf('   -> Total de respuestas válidas: %d\n', total_nps);
fprintf('   -> Promotores (9-10): %d (%.2f%%)\n', promotores, pct_prom);
fprintf('   -> Pasivos (7-8): %d (%.2f%%)\n', pasivos, pct_pas);
fprintf('   -> Detractores (0-6): %d (%.2f%%)\n', detractores, pct_det);
fprintf('   -> Índice Net Promoter Score (NPS): +%.2f / 100.00\n\n', nps_index);

% Simulación de Monte Carlo (10,000 iteraciones para modelar la densidad de probabilidad)
n_iteraciones = 10000;
media_muestral = mean(nps_raw);
desv_muestral = std(nps_raw);

% Generación de números aleatorios bajo distribución normal ajustada a la muestra
simulacion_nps = normrnd(media_muestral, desv_muestral, [n_iteraciones, 1]);
simulacion_nps = max(0, min(10, simulacion_nps)); % Restringir al rango lógico [0, 10]

fprintf('--- 3. SIMULACIÓN ESTOCÁSTICA MONTE CARLO (N = 10,000) ---\n');
fprintf('   -> Media estimada por simulación: %.2f / 10.00\n', mean(simulacion_nps));
fprintf('   -> Desviación estándar simulada: %.2f\n', std(simulacion_nps));
fprintf('   -> Intervalo de Confianza (95%%): [%.2f, %.2f]\n\n', prctile(simulacion_nps, 2.5), prctile(simulacion_nps, 97.5));

%% PASO 4: Procesamiento y Evaluación del Modelo SERVQUAL (11 Ítems)
% Extracción del bloque de preguntas SERVQUAL (Columnas 19 a 29)
servqual_raw = data{:, 19:29};
[N_filas, N_cols] = size(servqual_raw);
servqual_num = zeros(N_filas, N_cols);

% Mapeo automatizado de respuestas Likert textuales a valores numéricos discretos [1, 5]
for j = 1:N_cols
    col_data = string(servqual_raw(:, j));
    num_col = zeros(N_filas, 1);
    for k = 1:N_filas
        txt = char(col_data(k));
        if contains(txt, '1') || contains(lower(txt), 'totalmente en desacuerdo') || contains(lower(txt), 'insatisfecho')
            num_col(k) = 1;
        elseif contains(txt, '2') || contains(lower(txt), 'en desacuerdo')
            num_col(k) = 2;
        elseif contains(txt, '3') || contains(lower(txt), 'neutral')
            num_col(k) = 3;
        elseif contains(txt, '4') || contains(lower(txt), 'de acuerdo') || contains(lower(txt), 'satisfecho')
            num_col(k) = 4;
        elseif contains(txt, '5') || contains(lower(txt), 'totalmente de acuerdo') || contains(lower(txt), 'muy satisfecho')
            num_col(k) = 5;
        else
            num_col(k) = NaN; % Manejo de valores vacíos o no tipificados
        end
    end
    servqual_num(:, j) = num_col;
end

% Cálculo de estadísticos descriptivos por cada dimensión SERVQUAL
media_servqual = mean(servqual_num, 1, 'omitnan');
std_servqual = std(servqual_num, 0, 1, 'omitnan');
min_servqual = min(servqual_num, [], 1, 'omitnan');
max_servqual = max(servqual_num, [], 1, 'omitnan');

disp('--- 4. ESTADÍSTICAS DESCRIPTIVAS - DIMENSIONES SERVQUAL ---');
for j = 1:N_cols
    fprintf('   -> Dimensión %2d | Media: %.2f | Desv.Est.: %.2f | Min: %.1f | Max: %.1f\n', ...
        j, media_servqual(j), std_servqual(j), min_servqual(j), max_servqual(j));
end
fprintf('\n');

%% PASO 5: Análisis de Varianza (ANOVA Unidireccional) por Grupos de Edad
% Cálculo de la puntuación media global SERVQUAL para cada encuestado
media_global_por_encuestado = mean(servqual_num, 2, 'omitnan');

% Ejecución de ANOVA unidireccional para evaluar diferencias significativas entre grupos etarios
[p_anova, tabla_anova, estadisticos_anova] = anova1(media_global_por_encuestado, edad_grupo, 'off');

disp('--- 5. ANÁLISIS DE VARIANZA (ANOVA) - EDAD VS SATISFACCIÓN ---');
disp(tabla_anova);
fprintf('   -> Estadístico F obtenido: %.4f\n', tabla_anova{2, 5});
fprintf('   -> Valor p (p-value): %.4f\n', p_anova);

if p_anova < 0.05
    fprintf('   -> Conclusión: Se rechaza la hipótesis nula; existen diferencias estadísticamente significativas entre los grupos de edad.\n');
else
    fprintf('   -> Conclusión: No se rechaza la hipótesis nula al nivel estándar del 5%%.\n');
end