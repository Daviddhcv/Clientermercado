% =========================================================================
% SCRIPT MATLAB v4 — Análisis Estadístico Completo
% Mercado Municipal "Sauces 9" — Guayaquil, Ecuador
% n = 438 encuestados | Agosto 2026
%
% Genera: todas las estadísticas, tablas y figuras del manuscrito
% Autores: Cárdenas-Villacrés, Rojas-Párraga, Lara-Padilla, Rodríguez-Quintana
% Repositorio: https://github.com/Daviddhcv/Clientermercado
% =========================================================================

clear; clc; close all;

%% -----------------------------------------------------------------------
%  PASO 0: CONFIGURACIÓN Y CARGA DE DATOS
% -----------------------------------------------------------------------
filename = 'Encuesta a Clientes MERCADO SAUCES 9(1-438).xlsx';
data     = readtable(filename, 'FileType', 'spreadsheet');

fprintf('=======================================================\n');
fprintf(' ANÁLISIS ESTADÍSTICO — MERCADO SAUCES 9 (n=%d)\n', height(data));
fprintf('=======================================================\n\n');

% ---- Índices de columnas (base 1, MATLAB) ----
% Col  7 = Edad/Perfil del visitante
% Col  8 = Género
% Col  9 = Frecuencia de visita
% Col 10 = Horario de compra
% Col 12 = Factor principal de elección
% Col 14 = Puntuación NPS (0-10)
% Col 17 = Evacuación (SÍ / NO)
% Col 18 = Satisfacción global
% Col 19-29 = Ítems SERVQUAL (11 ítems)

edad_raw  = data{:, 7};
genero    = data{:, 8};
freq_raw  = data{:, 9};
horario   = data{:,10};
eleccion  = data{:,12};
nps_txt   = data{:,14};
evac_raw  = data{:,17};
sat_glob  = data{:,18};
sq_raw    = data{:,19:29};

%% -----------------------------------------------------------------------
%  PASO 1: CODIFICACIÓN LIKERT (1-5) — SERVQUAL
% -----------------------------------------------------------------------
N_resp = height(data);
N_items = 11;
sq_num = NaN(N_resp, N_items);

for j = 1:N_items
    col = string(sq_raw(:, j));
    for k = 1:N_resp
        txt = lower(char(col(k)));
        if contains(txt,'totalmente en desacuerdo') || contains(txt,'(1)')
            sq_num(k,j) = 1;
        elseif contains(txt,'en desacuerdo') || contains(txt,'(2)')
            sq_num(k,j) = 2;
        elseif contains(txt,'neutral') || contains(txt,'(3)')
            sq_num(k,j) = 3;
        elseif contains(txt,'totalmente de acuerdo') || contains(txt,'(5)')
            sq_num(k,j) = 5;
        elseif contains(txt,'de acuerdo') || contains(txt,'(4)')
            sq_num(k,j) = 4;
        end
    end
end

% Puntuación agregada por respondente
sq_agg = mean(sq_num, 2, 'omitnan');

%% -----------------------------------------------------------------------
%  PASO 2: CODIFICACIÓN DE VARIABLES CATEGÓRICAS
% -----------------------------------------------------------------------

% -- Edad (código ordinal 1-4) --
edad_str = string(edad_raw);
edad_cod = NaN(N_resp,1);
edad_cod(contains(edad_str,'18'))  = 1;  % 18-29
edad_cod(contains(edad_str,'30'))  = 2;  % 30-49
edad_cod(contains(edad_str,'50'))  = 3;  % 50-64
edad_cod(contains(edad_str,'65'))  = 4;  % ≥65
edad_lbl = {'18–29','30–49','50–64','≥65'};
edad_n   = [sum(edad_cod==1), sum(edad_cod==2), ...
            sum(edad_cod==3), sum(edad_cod==4)];

% -- Género --
gen_str = string(genero);
n_fem = sum(contains(gen_str,'emen'));
n_mas = N_resp - n_fem;

% -- NPS (numérico) --
nps_num = NaN(N_resp,1);
for k = 1:N_resp
    val = str2double(string(nps_txt(k)));
    if ~isnan(val), nps_num(k) = val; end
end
nps_valid = nps_num(~isnan(nps_num));

% -- Evacuación (lógico) --
evac_str = string(evac_raw);
evac_si  = contains(evac_str,'SÍ') | contains(evac_str,'SI');
evac_no  = ~evac_si;

%% -----------------------------------------------------------------------
%  PASO 3: DEMOGRAFÍA — TABLA 1
% -----------------------------------------------------------------------
fprintf('--- TABLA 1: DISTRIBUCIÓN SOCIODEMOGRÁFICA ---\n');
fprintf('Femenino : %d (%.2f%%)\n', n_fem, n_fem/N_resp*100);
fprintf('Masculino: %d (%.2f%%)\n', n_mas, n_mas/N_resp*100);
fprintf('\n');
edad_lbl_full = {'18-29 años','30-49 años','50-64 años','≥65 años'};
for g = 1:4
    fprintf('  %s: n=%d (%.2f%%)\n', edad_lbl_full{g}, edad_n(g), edad_n(g)/N_resp*100);
end
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 4: FRECUENCIA DE VISITA — TABLA 2
% -----------------------------------------------------------------------
freq_str = string(freq_raw);
n_dias = sum(contains(freq_str,'Diario') | contains(freq_str,'diario'));
n_23   = sum(contains(freq_str,'2 a 3') | contains(freq_str,'2-3'));
n_sem  = sum(contains(freq_str,'fines') | contains(freq_str,'Semanal'));
n_quin = sum(contains(freq_str,'Quincen') | contains(freq_str,'mensual'));
n_freq_total = n_dias + n_23 + n_sem + n_quin;

fprintf('--- TABLA 2: FRECUENCIA DE VISITA (n=%d) ---\n', n_freq_total);
fprintf('  Diario            : %d (%.2f%%)\n', n_dias, n_dias/n_freq_total*100);
fprintf('  2-3 veces/semana  : %d (%.2f%%)\n', n_23,   n_23/n_freq_total*100);
fprintf('  Semanal (f/s)     : %d (%.2f%%)\n', n_sem,  n_sem/n_freq_total*100);
fprintf('  Quincenal/Mensual : %d (%.2f%%)\n', n_quin, n_quin/n_freq_total*100);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 5: HORARIO DE COMPRA — TABLA 3
% -----------------------------------------------------------------------
hor_str = string(horario);
% Conteo primario por mención del horario en respuesta (puede ser múltiple)
n_man   = sum(contains(hor_str,'06:00') | contains(hor_str,'Mañana') | contains(hor_str,'ma'));
n_medio = sum(contains(hor_str,'10:00') | contains(hor_str,'Media') | contains(hor_str,'Almuerzo'));
n_tarde = sum(contains(hor_str,'13:00') | contains(hor_str,'Tarde'));

% Horario primario exclusivo (primera mención)
hor_prim = NaN(N_resp,1);
for k = 1:N_resp
    t = lower(char(hor_str(k)));
    if contains(t,'06') || (contains(t,'ma') && ~contains(t,'10') && ~contains(t,'13'))
        hor_prim(k) = 1;
    elseif contains(t,'10') || contains(t,'almuerzo')
        hor_prim(k) = 2;
    elseif contains(t,'13') || contains(t,'tarde')
        hor_prim(k) = 3;
    end
end
n_h1 = sum(hor_prim==1); n_h2 = sum(hor_prim==2); n_h3 = sum(hor_prim==3);
% Mixed: respondentes que reportaron más de un horario
n_mix = N_resp - n_h1 - n_h2 - n_h3;

fprintf('--- TABLA 3: HORARIO DE COMPRA (n=%d) ---\n', N_resp);
fprintf('  Mañana (06-10h)   : %d (%.2f%%)\n', n_h1, n_h1/N_resp*100);
fprintf('  Mediodía (10-13h) : %d (%.2f%%)\n', n_h2, n_h2/N_resp*100);
fprintf('  Tarde (13h+)      : %d (%.2f%%)\n', n_h3, n_h3/N_resp*100);
fprintf('  Múltiple/Mixto    : %d (%.2f%%)\n', n_mix,n_mix/N_resp*100);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 6: FACTOR DE ELECCIÓN — TABLA 4
% -----------------------------------------------------------------------
elec_str = string(eleccion);
% Conteo por mención (respuesta múltiple posible)
n_fresc = sum(contains(elec_str,'rescura') | contains(elec_str,'calidad'));
n_cerca = sum(contains(elec_str,'ercana') | contains(elec_str,'omicilio') | contains(elec_str,'trabajo'));
n_yapa  = sum(contains(elec_str,'yapa') | contains(elec_str,'Yapa') | contains(lower(elec_str),'precio'));
n_trad  = sum(contains(elec_str,'radici') | contains(elec_str,'astronom'));
n_vari  = sum(contains(elec_str,'ariedad'));

fprintf('--- TABLA 4: FACTORES DE ELECCIÓN (menciones múltiples) ---\n');
fprintf('  Frescura y calidad          : %d menciones\n', n_fresc);
fprintf('  Cercanía domicilio/trabajo  : %d menciones\n', n_cerca);
fprintf('  Precios / Yapa              : %d menciones\n', n_yapa);
fprintf('  Tradición y gastronomía     : %d menciones\n', n_trad);
fprintf('  Variedad de oferta          : %d menciones\n', n_vari);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 7: ALPHA DE CRONBACH + CORRELACIONES ÍTEM-TOTAL
% -----------------------------------------------------------------------
fprintf('--- VALIDACIÓN PSICOMÉTRICA SERVQUAL ---\n');

% Alpha global
k = N_items;
item_vars = var(sq_num, 0, 1);       % varianza de cada ítem (ddof=1 en MATLAB es default)
total_var = var(sum(sq_num, 2, 'omitnan'));
alpha_global = (k/(k-1)) * (1 - sum(item_vars)/total_var);
fprintf('Cronbach alpha (11 ítems): %.4f\n', alpha_global);

% Correlaciones ítem-total corregidas + alpha si se elimina
fprintf('\nCorrelaciones ítem-total corregidas:\n');
item_labels = {'P1-Frescura','P2-Pesaje','P3-Precio','P4-Disponib.','P5-Velocidad',...
               'P6-Respuesta','P7-Higiene','P8-Confianza','P9-Trato','P10-Adaptac.','P11-Horario'};

corr_it = NaN(1,k);
alpha_del = NaN(1,k);
for j = 1:k
    rest = sq_num;
    rest(:,j) = [];
    rest_sum = sum(rest, 2, 'omitnan');
    % Pearson r entre ítem j y suma del resto
    valid_idx = ~isnan(sq_num(:,j)) & ~isnan(rest_sum);
    c = corrcoef(sq_num(valid_idx,j), rest_sum(valid_idx));
    corr_it(j) = c(1,2);
    % Alpha si se elimina
    k2 = k-1;
    iv2 = var(rest, 0, 1);
    tv2 = var(sum(rest, 2, 'omitnan'));
    alpha_del(j) = (k2/(k2-1))*(1-sum(iv2)/tv2);
    fprintf('  %s: r=%.3f, alpha_if_deleted=%.4f\n', item_labels{j}, corr_it(j), alpha_del(j));
end
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 8: ESTADÍSTICOS DESCRIPTIVOS SERVQUAL — TABLA 5
% -----------------------------------------------------------------------
fprintf('--- TABLA 5: DESCRIPTIVOS SERVQUAL (n=%d, alpha=%.2f) ---\n', N_resp, alpha_global);
fprintf('%-30s  Mean    SD   Min  Max\n','Ítem');
item_means = NaN(1,k); item_sd = NaN(1,k);
for j = 1:k
    col = sq_num(:,j);
    col = col(~isnan(col));
    item_means(j) = mean(col);
    item_sd(j)    = std(col);
    fprintf('  %-28s  %.4f  %.4f  %d    %d\n', item_labels{j}, ...
        item_means(j), item_sd(j), min(col), max(col));
end
fprintf('  %-28s  %.4f\n','Aggregated Mean', mean(sq_agg,'omitnan'));
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 9: NPS Y BOOTSTRAP — TABLA 6
% -----------------------------------------------------------------------
fprintf('--- TABLA 6: NPS Y BOOTSTRAP ---\n');
n_valid = length(nps_valid);
n_P  = sum(nps_valid >= 9);
n_Pa = sum(nps_valid >= 7 & nps_valid <= 8);
n_D  = sum(nps_valid <= 6);
pct_P = n_P/n_valid*100;
pct_Pa= n_Pa/n_valid*100;
pct_D = n_D/n_valid*100;
NPS   = pct_P - pct_D;

% Intervalo de confianza analítico (método de Wilson/SE propagada)
% SE del NPS = sqrt(Var(P%-D%))
% Var(P%) = p_P(1-p_P)/n; Var(D%) = p_D(1-p_D)/n; Cov(P,D)= -p_P*p_D/n (mutually exclusive)
p_P = n_P/n_valid; p_D = n_D/n_valid;
SE_NPS = sqrt( (p_P*(1-p_P) + p_D*(1-p_D) + 2*p_P*p_D) / n_valid ) * 100;
CI_lo  = NPS - 1.96*SE_NPS;
CI_hi  = NPS + 1.96*SE_NPS;

fprintf('  Promotores  (9-10): %d (%.2f%%)\n', n_P,  pct_P);
fprintf('  Pasivos     (7-8) : %d (%.2f%%)\n', n_Pa, pct_Pa);
fprintf('  Detractores (0-6) : %d (%.2f%%)\n', n_D,  pct_D);
fprintf('  NPS Index         : +%.2f\n', NPS);
fprintf('  SE(NPS)           : %.4f\n', SE_NPS);
fprintf('  95%% CI (analitico): [%.2f, %.2f]\n', CI_lo, CI_hi);

% Bootstrap (10,000 iteraciones, no paramétrico)
rng(42);
n_boot = 10000;
nps_boot = NaN(n_boot,1);
mean_boot = NaN(n_boot,1);
for b = 1:n_boot
    samp = nps_valid(randi(n_valid, n_valid, 1));
    bp = sum(samp>=9)/n_valid*100;
    bd = sum(samp<=6)/n_valid*100;
    nps_boot(b)  = bp - bd;
    mean_boot(b) = mean(samp);
end
fprintf('  Bootstrap NPS media     : %.4f\n', mean(nps_boot));
fprintf('  Bootstrap score medio   : %.4f\n', mean(mean_boot));
fprintf('  Bootstrap 95%% CI (perc) : [%.2f, %.2f]\n', ...
    prctile(nps_boot,2.5), prctile(nps_boot,97.5));

% Análisis de sensibilidad (especificaciones alternativas)
n_D7 = sum(nps_valid<=7);
NPS_D7 = (n_P - n_D7)/n_valid*100;
n_P8 = sum(nps_valid>=8);
NPS_P8 = (n_P8 - n_D)/n_valid*100;
fprintf('\n  Sensibilidad:\n');
fprintf('    Detractores redefinidos (0-7): NPS = %.2f\n', NPS_D7);
fprintf('    Promotores redefinidos  (8-10): NPS = %.2f\n', NPS_P8);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 10: ANOVA UNA VÍA (SATISFACCIÓN × EDAD) — TABLA 7
% -----------------------------------------------------------------------
fprintf('--- TABLA 7: ANOVA (SERVQUAL agg × Grupo de Edad) ---\n');

grupos = cell(4,1);
for g = 1:4
    grupos{g} = sq_agg(edad_cod == g & ~isnan(sq_agg));
end

% Medias por grupo
fprintf('  Medias por grupo:\n');
for g = 1:4
    fprintf('    %s: n=%d, mean=%.4f\n', edad_lbl{g}, length(grupos{g}), mean(grupos{g}));
end

% ANOVA manual (para reportar SS detallado)
todos = sq_agg(~isnan(sq_agg));
grand_mean = mean(todos);
N_anova = length(todos);

SS_b = 0;
for g = 1:4
    SS_b = SS_b + length(grupos{g}) * (mean(grupos{g}) - grand_mean)^2;
end
SS_t = sum((todos - grand_mean).^2);
SS_w = SS_t - SS_b;
df_b = 3; df_w = N_anova - 4; df_t = N_anova - 1;
MS_b = SS_b/df_b; MS_w = SS_w/df_w;
F_stat = MS_b/MS_w;
p_anova = 1 - fcdf(F_stat, df_b, df_w);
eta2 = SS_b/SS_t;

fprintf('\n  Source          SS        df     MS        F       p\n');
fprintf('  Between     %8.3f    %3d  %8.3f   %6.3f  %.4f\n', SS_b,df_b,MS_b,F_stat,p_anova);
fprintf('  Within      %8.3f    %3d  %8.3f\n', SS_w,df_w,MS_w);
fprintf('  Total       %8.3f    %3d\n', SS_t,df_t);
fprintf('  eta2 = %.4f\n', eta2);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 11: TEST DE JONCKHEERE-TERPSTRA (tendencia monótona)
% -----------------------------------------------------------------------
fprintf('--- TEST DE JONCKHEERE-TERPSTRA (tendencia ordenada) ---\n');

% Estadístico JT = Suma de U-Mann-Whitney para todos los pares ordenados
JT_stat = 0;
Ns_jt = cellfun(@length, grupos);
N_jt  = sum(Ns_jt);
for i = 1:4
    for j = i+1:4
        for xi = grupos{i}'
            for xj = grupos{j}'
                if xj > xi,     JT_stat = JT_stat + 1;
                elseif xj == xi, JT_stat = JT_stat + 0.5;
                end
            end
        end
    end
end

% Valor esperado bajo H0
E_JT = (N_jt^2 - sum(Ns_jt.^2)) / 4;

% Varianza con corrección por empates
pooled_all = vertcat(grupos{:});
[u_vals, u_cnts] = groupcounts(pooled_all);
tie_term   = sum(u_cnts .* (u_cnts-1) .* (2*u_cnts+5));
group_term = sum(Ns_jt .* (Ns_jt-1) .* (2*Ns_jt+5));
N_term     = N_jt * (N_jt-1) * (2*N_jt+5);
Var_JT     = (N_term - group_term - tie_term) / 72;

Z_JT  = (JT_stat - E_JT) / sqrt(Var_JT);
p_JT  = 1 - normcdf(Z_JT);   % una cola (hipótesis alternativa direccional)

fprintf('  JT = %.1f   E(JT) = %.1f   Var(JT) = %.1f\n', JT_stat, E_JT, Var_JT);
fprintf('  Z  = %.4f   p (una cola) = %.4f\n', Z_JT, p_JT);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 12: CHI-CUADRADO EDAD × FRECUENCIA — TABLA 8
% -----------------------------------------------------------------------
fprintf('--- TABLA 8: CHI2 EDAD × FRECUENCIA DE VISITA ---\n');

freq_str2 = string(freq_raw);
freq_cod = NaN(N_resp,1);
freq_cod(contains(freq_str2,'Diario')|contains(freq_str2,'diario'))       = 1;
freq_cod(contains(freq_str2,'2 a 3')|contains(freq_str2,'2-3'))           = 2;
freq_cod(contains(freq_str2,'fines')|contains(lower(freq_str2),'semanal'))= 3;
freq_cod(contains(freq_str2,'Quincen')|contains(freq_str2,'mensual'))     = 4;

% Tabla de contingencia 4x4
ct_freq = zeros(4,4);
for g = 1:4
    for f = 1:4
        ct_freq(g,f) = sum(edad_cod==g & freq_cod==f);
    end
end
freq_lbl = {'Diario','2-3x/sem','Semanal','Quincenal'};
fprintf('\n  Tabla de contingencia (filas=Edad, cols=Frecuencia):\n');
fprintf('              %-12s %-12s %-12s %-12s Total\n', freq_lbl{:});
for g = 1:4
    row_tot = sum(ct_freq(g,:));
    fprintf('  %-10s', edad_lbl{g});
    for f = 1:4
        fprintf('  %3d(%5.1f%%)', ct_freq(g,f), ct_freq(g,f)/row_tot*100);
    end
    fprintf('  %3d\n', row_tot);
end
col_tots = sum(ct_freq,1); tot = sum(col_tots);
fprintf('  %-10s  %3d          %3d          %3d          %3d       %3d\n',...
    'Total',col_tots(1),col_tots(2),col_tots(3),col_tots(4),tot);

% Chi-cuadrado de Pearson
E_freq = (sum(ct_freq,2) * sum(ct_freq,1)) / tot;
chi2_freq = sum(sum((ct_freq - E_freq).^2 ./ E_freq));
df_chi2 = (4-1)*(4-1);
p_chi2_freq = 1 - chi2cdf(chi2_freq, df_chi2);
V_freq = sqrt(chi2_freq / (tot*(min(size(ct_freq))-1)));

fprintf('\n  chi2=%.3f  df=%d  p=%.4f  Cramér V=%.3f\n', chi2_freq,df_chi2,p_chi2_freq,V_freq);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 13: CHI-CUADRADO EDAD × EVACUACIÓN — TABLA 9
% -----------------------------------------------------------------------
fprintf('--- TABLA 9: CHI2 EDAD × CONCIENCIA DE EVACUACIÓN ---\n');

evac_si_log = contains(string(evac_raw),'SÍ') | contains(string(evac_raw),'SI');

ct_evac = zeros(4,2);   % col1=NO, col2=SÍ
for g = 1:4
    idx = edad_cod==g;
    ct_evac(g,1) = sum(idx & ~evac_si_log);
    ct_evac(g,2) = sum(idx & evac_si_log);
end

fprintf('\n  Grupo        NO (%%Ignore)  SÍ (%%Aware)\n');
for g = 1:4
    rt = sum(ct_evac(g,:));
    fprintf('  %-10s  %3d (%5.1f%%)   %3d (%5.1f%%)\n', edad_lbl{g},...
        ct_evac(g,1), ct_evac(g,1)/rt*100, ct_evac(g,2), ct_evac(g,2)/rt*100);
end
fprintf('  Total        %3d           %3d\n', sum(ct_evac(:,1)), sum(ct_evac(:,2)));

n_evac = sum(ct_evac(:));
E_evac = (sum(ct_evac,2) * sum(ct_evac,1)) / n_evac;
chi2_evac = sum(sum((ct_evac - E_evac).^2 ./ E_evac));
df_evac = (4-1)*(2-1);
p_evac = 1 - chi2cdf(chi2_evac, df_evac);
V_evac = sqrt(chi2_evac / (n_evac*(min(size(ct_evac))-1)));

fprintf('\n  chi2=%.3f  df=%d  p=%.4f  Cramér V=%.3f\n', chi2_evac,df_evac,p_evac,V_evac);
fprintf('  Total no informados: %d (%.2f%%)\n', sum(ct_evac(:,1)), sum(ct_evac(:,1))/n_evac*100);
fprintf('\n');

%% -----------------------------------------------------------------------
%  PASO 14: GRÁFICAS DE ALTA CALIDAD (300 DPI, formato publicación)
% -----------------------------------------------------------------------

clr_blue  = [0.24 0.46 0.71];
clr_green = [0.18 0.55 0.34];
clr_red   = [0.74 0.23 0.20];
clr_orange= [0.88 0.55 0.24];
clr_grey  = [0.45 0.45 0.45];
bar_colors = {[0.53 0.74 0.75],[0.29 0.56 0.64],[0.17 0.39 0.52],[0.09 0.24 0.35]};

fig_opts = {'Units','inches','Position',[0 0 7 4.5]};

% ============================================================
%  FIGURA 1 — Distribución por Edad
% ============================================================
fig1 = figure('visible','off', fig_opts{:});
edad_counts = [101 215 94 28];
edad_pcts   = edad_counts/438*100;
b1 = bar(1:4, edad_counts, 0.6, 'FaceColor','flat');
for g=1:4, b1.CData(g,:) = bar_colors{g}; end
set(gca,'XTickLabel',{'18–29\nyears','30–49\nyears','50–64\nyears','≥65\nyears'},...
    'FontSize',10,'TickLabelInterpreter','tex','Box','off')
xlabel('Age Group','FontSize',11,'FontWeight','bold')
ylabel('Number of Respondents','FontSize',11,'FontWeight','bold')
title('Distribution by Age Group (n = 438)','FontSize',12,'FontWeight','bold')
for g=1:4
    text(g, edad_counts(g)+3, sprintf('%d\n(%.1f%%)',edad_counts(g),edad_pcts(g)),...
        'HorizontalAlignment','center','FontSize',9)
end
ylim([0 250]); grid on; grid minor;
exportgraphics(fig1,'fig1_age_distribution.jpg','Resolution',300)
fprintf('Figura 1 guardada: fig1_age_distribution.jpg\n');

% ============================================================
%  FIGURA 2 — Frecuencia de Visita
% ============================================================
fig2 = figure('visible','off', fig_opts{:});
freq_vals = [139 115 95 88];
freq_lbl2 = {'Weekend\nWeekly','2–3×/week','Biweekly/\nMonthly','Daily'};
freq_pcts = freq_vals/437*100;
b2 = bar(1:4, freq_vals, 0.6, 'FaceColor','flat');
cc2 = [0.44 0.55 0.73; 0.33 0.44 0.63; 0.22 0.33 0.53; 0.12 0.23 0.43];
for g=1:4, b2.CData(g,:) = cc2(g,:); end
set(gca,'XTickLabel',freq_lbl2,'FontSize',10,'TickLabelInterpreter','tex','Box','off')
xlabel('Visit Frequency Category','FontSize',11,'FontWeight','bold')
ylabel('Number of Respondents','FontSize',11,'FontWeight','bold')
title('Weekly Visit Frequency (n = 437)','FontSize',12,'FontWeight','bold')
for g=1:4
    text(g, freq_vals(g)+2, sprintf('%d\n(%.1f%%)',freq_vals(g),freq_pcts(g)),...
        'HorizontalAlignment','center','FontSize',9)
end
ylim([0 165]); grid on;
exportgraphics(fig2,'fig2_visit_frequency.jpg','Resolution',300)
fprintf('Figura 2 guardada: fig2_visit_frequency.jpg\n');

% ============================================================
%  FIGURA 3 — Horario de Compra
% ============================================================
fig3 = figure('visible','off', fig_opts{:});
hor_vals = [256 137 12 33];
hor_lbl2 = {'Morning\n(06–10h)','Midday\n(10–13h)','Afternoon\n(13h+)','Multiple'};
hor_pcts = hor_vals/438*100;
b3 = bar(1:4, hor_vals, 0.6, 'FaceColor','flat');
cc3 = [0.88 0.60 0.25; 0.75 0.42 0.18; 0.58 0.28 0.10; 0.40 0.18 0.05];
for g=1:4, b3.CData(g,:) = cc3(g,:); end
set(gca,'XTickLabel',hor_lbl2,'FontSize',10,'TickLabelInterpreter','tex','Box','off')
xlabel('Time Window','FontSize',11,'FontWeight','bold')
ylabel('Number of Respondents','FontSize',11,'FontWeight','bold')
title('Preferred Shopping Schedule (n = 438)','FontSize',12,'FontWeight','bold')
for g=1:4
    text(g, hor_vals(g)+3, sprintf('%d\n(%.1f%%)',hor_vals(g),hor_pcts(g)),...
        'HorizontalAlignment','center','FontSize',9)
end
ylim([0 295]); grid on;
exportgraphics(fig3,'fig3_shopping_schedule.jpg','Resolution',300)
fprintf('Figura 3 guardada: fig3_shopping_schedule.jpg\n');

% ============================================================
%  FIGURA 4 — Factores de Elección (barras horizontales)
% ============================================================
fig4 = figure('visible','off', fig_opts{:});
fac_vals = [n_fresc, n_cerca, n_yapa, n_trad, n_vari];
fac_lbl  = {'Freshness & Quality','Proximity','Pricing & \it{Yapa}','Tradition & Food','Product Variety'};
[fac_sort, idx_sort] = sort(fac_vals,'ascend');
barh(1:5, fac_sort, 0.55, 'FaceColor','flat', 'CData', ...
    [0.55 0.18 0.16; 0.66 0.25 0.18; 0.78 0.33 0.18; 0.88 0.48 0.24; 0.92 0.65 0.35])
set(gca,'YTickLabel',fac_lbl(idx_sort),'FontSize',10,'Box','off')
xlabel('Number of Mentions','FontSize',11,'FontWeight','bold')
title('Choice Factors: Market vs. Supermarket (n = 438, multiple-choice)','FontSize',11,'FontWeight','bold')
for g=1:5
    text(fac_sort(g)+3, g, sprintf('%d',fac_sort(g)),'FontSize',9,'VerticalAlignment','middle')
end
grid on;
exportgraphics(fig4,'fig4_choice_factors.jpg','Resolution',300)
fprintf('Figura 4 guardada: fig4_choice_factors.jpg\n');

% ============================================================
%  FIGURA 5 — Satisfacción Global (NPS promotores/pasivos/detractores)
% ============================================================
fig5 = figure('visible','off', fig_opts{:});
nps_cats = [n_P n_Pa n_D];
nps_pcts = nps_cats/n_valid*100;
nps_lbl2 = {sprintf('Promoters\n(9-10)\nn=%d',n_P), ...
             sprintf('Passives\n(7-8)\nn=%d',n_Pa), ...
             sprintf('Detractors\n(0-6)\nn=%d',n_D)};
colors5 = [0.18 0.55 0.34; 0.70 0.75 0.70; 0.74 0.23 0.20];
b5 = bar(1:3, nps_cats, 0.55, 'FaceColor','flat');
for g=1:3, b5.CData(g,:) = colors5(g,:); end
set(gca,'XTickLabel',nps_lbl2,'FontSize',10,'TickLabelInterpreter','tex','Box','off')
ylabel('Number of Respondents','FontSize',11,'FontWeight','bold')
title(sprintf('NPS Category Distribution (NPS = +%.2f; n = 438)',NPS),...
    'FontSize',11,'FontWeight','bold')
for g=1:3
    text(g, nps_cats(g)+2, sprintf('%.1f%%',nps_pcts(g)),...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold')
end
ylim([0 360]); grid on;
exportgraphics(fig5,'fig5_nps_categories.jpg','Resolution',300)
fprintf('Figura 5 guardada: fig5_nps_categories.jpg\n');

% ============================================================
%  FIGURA 6 — Simulación Bootstrap (distribución NPS)
% ============================================================
fig6 = figure('visible','off', fig_opts{:});
histogram(nps_boot, 40, 'FaceColor',[0.24 0.65 0.70],'EdgeColor','white','FaceAlpha',0.85,...
    'Normalization','count')
hold on;
xline(mean(nps_boot),'r--','LineWidth',2,...
    'Label',sprintf('Mean = %.2f', mean(nps_boot)),'FontSize',10,'LabelVerticalAlignment','bottom')
xline(prctile(nps_boot,2.5),'k:','LineWidth',1.5,'Label','2.5%','FontSize',9)
xline(prctile(nps_boot,97.5),'k:','LineWidth',1.5,'Label','97.5%','FontSize',9)
xlabel('NPS Index','FontSize',11,'FontWeight','bold')
ylabel('Frequency (Bootstrap iterations)','FontSize',11,'FontWeight','bold')
title(sprintf('Bootstrap Distribution of NPS (10,000 iterations)\n95%% CI = [%.2f, %.2f]',...
    prctile(nps_boot,2.5),prctile(nps_boot,97.5)),'FontSize',11,'FontWeight','bold')
grid on; box off;
exportgraphics(fig6,'fig6_bootstrap_nps.jpg','Resolution',300)
fprintf('Figura 6 guardada: fig6_bootstrap_nps.jpg\n');

% ============================================================
%  FIGURA 7 — Perfil SERVQUAL (radar/spider simplificado con barras)
% ============================================================
fig7 = figure('visible','off','Units','inches','Position',[0 0 8 5]);
item_short = {'P1 Freshness','P2 Weighting','P3 Price','P4 Availability',...
              'P5 Speed','P6 Response','P7 Hygiene','P8 Trust','P9 Treatment',...
              'P10 Adaptation','P11 Schedule'};
barh(1:11, item_means, 0.6, 'FaceColor', clr_blue, 'FaceAlpha', 0.85)
hold on;
errorbar(item_means, 1:11, item_sd, 'horizontal','k.','LineWidth',1)
xline(mean(item_means),'r--','LineWidth',1.5,'Label',sprintf('Mean=%.2f',mean(item_means)))
set(gca,'YTickLabel',item_short,'FontSize',9,'Box','off')
xlabel('Mean Score (1–5 Likert)','FontSize',11,'FontWeight','bold')
title(sprintf('SERVQUAL Item Means (n = 438, α = %.2f)',alpha_global),'FontSize',11,'FontWeight','bold')
xlim([3.5 5.0]); grid on;
exportgraphics(fig7,'fig7_servqual_profile.jpg','Resolution',300)
fprintf('Figura 7 guardada: fig7_servqual_profile.jpg\n');

% ============================================================
%  FIGURA 8 — Medias SERVQUAL por Grupo de Edad
% ============================================================
fig8 = figure('visible','off', fig_opts{:});
age_means = cellfun(@mean, grupos);
age_sem   = cellfun(@(x) std(x)/sqrt(length(x)), grupos);
b8 = bar(1:4, age_means, 0.55, 'FaceColor','flat');
for g=1:4, b8.CData(g,:) = bar_colors{g}; end
hold on;
errorbar(1:4, age_means, age_sem,'k.','LineWidth',1.5,'CapSize',8)
set(gca,'XTickLabel',{'18–29','30–49','50–64','≥65'},'FontSize',11,'Box','off')
xlabel('Age Cohort','FontSize',11,'FontWeight','bold')
ylabel('Mean SERVQUAL Score (1–5)','FontSize',11,'FontWeight','bold')
title(sprintf('SERVQUAL Aggregated Mean by Age Cohort\nANOVA: F=%.3f, p=%.3f, η²=%.3f | JT: Z=%.2f, p=%.3f',...
    F_stat,p_anova,eta2,Z_JT,p_JT),'FontSize',10,'FontWeight','bold')
for g=1:4
    text(g, age_means(g)+0.01, sprintf('%.3f',age_means(g)),...
        'HorizontalAlignment','center','FontSize',9.5)
end
ylim([4.0 4.7]); grid on;
exportgraphics(fig8,'fig8_servqual_by_age.jpg','Resolution',300)
fprintf('Figura 8 guardada: fig8_servqual_by_age.jpg\n');

% ============================================================
%  FIGURA 9 — Conciencia Evacuación por Edad (stacked bar 100%)
% ============================================================
fig9 = figure('visible','off', fig_opts{:});
evac_pct_no = ct_evac(:,1)./sum(ct_evac,2)*100;
evac_pct_si = ct_evac(:,2)./sum(ct_evac,2)*100;
b9 = bar(1:4, [evac_pct_no, evac_pct_si], 0.6, 'stacked');
b9(1).FaceColor = clr_red;
b9(2).FaceColor = clr_green;
set(gca,'XTickLabel',{'18–29','30–49','50–64','≥65'},'FontSize',11,'Box','off')
xlabel('Age Cohort','FontSize',11,'FontWeight','bold')
ylabel('Percentage (%)','FontSize',11,'FontWeight','bold')
title(sprintf('Evacuation Route Awareness by Age Cohort\nχ²=%.3f, p=%.3f, Cramér V=%.3f',...
    chi2_evac,p_evac,V_evac),'FontSize',10,'FontWeight','bold')
legend({'Unaware (No)','Aware (Yes)'},'Location','southoutside','Orientation','horizontal')
for g=1:4
    text(g, evac_pct_no(g)/2, sprintf('%.1f%%',evac_pct_no(g)),...
        'HorizontalAlignment','center','Color','white','FontSize',10,'FontWeight','bold')
    text(g, evac_pct_no(g)+evac_pct_si(g)/2, sprintf('%.1f%%',evac_pct_si(g)),...
        'HorizontalAlignment','center','Color','white','FontSize',10,'FontWeight','bold')
end
ylim([0 110]); grid on;
exportgraphics(fig9,'fig9_evacuation_by_age.jpg','Resolution',300)
fprintf('Figura 9 guardada: fig9_evacuation_by_age.jpg\n');

% ============================================================
%  FIGURA 10 — Bootstrap score medio (distribución de densidad)
% ============================================================
fig10 = figure('visible','off', fig_opts{:});
[f_kde, xi_kde] = ksdensity(mean_boot);
area(xi_kde, f_kde*length(mean_boot)*(xi_kde(2)-xi_kde(1))*length(mean_boot)/max(f_kde),...
    'FaceColor',[0.24 0.65 0.70],'FaceAlpha',0.4,'EdgeColor',[0.10 0.50 0.55],'LineWidth',1.5)
hold on;
xline(mean(mean_boot),'r--','LineWidth',2,...
    'Label',sprintf('Mean = %.4f',mean(mean_boot)),'LabelVerticalAlignment','bottom','FontSize',10)
xlabel('Bootstrap Mean Recommendation Score (0–10)','FontSize',11,'FontWeight','bold')
ylabel('Density','FontSize',11,'FontWeight','bold')
title('Bootstrap Probability Density — Recommendation Score (10,000 iterations)',...
    'FontSize',11,'FontWeight','bold')
grid on; box off;
exportgraphics(fig10,'fig10_bootstrap_score_density.jpg','Resolution',300)
fprintf('Figura 10 guardada: fig10_bootstrap_score_density.jpg\n');

fprintf('\n=======================================================\n');
fprintf(' ANÁLISIS COMPLETADO EXITOSAMENTE\n');
fprintf(' Estadísticos principales:\n');
fprintf('   Alpha de Cronbach : %.4f\n', alpha_global);
fprintf('   NPS               : +%.2f (95%% CI [%.2f, %.2f])\n', NPS, CI_lo, CI_hi);
fprintf('   NPS Bootstrap mean: %.4f\n', mean(nps_boot));
fprintf('   ANOVA F           : %.3f (p=%.4f, eta2=%.4f)\n', F_stat, p_anova, eta2);
fprintf('   JT Z              : %.4f (p=%.4f)\n', Z_JT, p_JT);
fprintf('   Chi2 Edad×Freq    : %.3f (p=%.4f, V=%.3f)\n', chi2_freq, p_chi2_freq, V_freq);
fprintf('   Chi2 Edad×Evac    : %.3f (p=%.4f, V=%.3f)\n', chi2_evac, p_evac, V_evac);
fprintf('=======================================================\n');
