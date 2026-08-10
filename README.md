# Cetana Fair Crisis

Mini-mod para Stellaris que convierte la guerra inicial de Cetana contra los
Imperios Caídos/Despertados en un enfrentamiento real, sin reducir su potencia
general ni alterar la cadena vanilla cuando Cetana vence.

## Resumen ejecutivo

El mod mantiene intacta la aparición vanilla de Cetana, pero elimina las reglas
que fuerzan prácticamente su victoria inicial:

- Cetana deja de recibir su `+200 %` específico de daño contra Imperios
  Caídos/Despertados.
- Los Imperios Caídos/Despertados dejan de sufrir el `-90 %` específico de daño
  contra Cetana.
- Se neutralizan la destrucción programada de flotas/colonias y la expulsión de
  flotas FE/AE por la tormenta durante esta fase.
- Un imperio normal puede intervenir voluntariamente desde el contacto
  diplomático con Cetana, sin provocar una guerra automática para los demás.
- Si Cetana vence a todos los FE/AE, `crisis.8043` recupera el control y toda la
  cadena posterior continúa de forma vanilla.
- Si el titán de Cetana es destruido prematuramente, el mod impide que arranque
  después la situación normal y deja que `crisis.23015` ejecute el cierre
  vanilla completo, incluidos los trackers necesarios para **All Crises**.

No se ha usado `kill_country`, no se ha modificado ningún archivo original y no
se altera la potencia general, regeneración, velocidad, flotas o escalado de
Cetana.

## Árbol del proyecto

```text
.
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── descriptor.mod
├── cetana_fair_crisis.mod
├── common/
│   ├── on_actions/cfc_on_actions.txt
│   ├── scripted_effects/cfc_scripted_effects.txt
│   ├── scripted_triggers/cfc_scripted_triggers.txt
│   ├── static_modifiers/cfc_queen_combat_modifiers.txt
│   └── war_goals/cfc_cetana_war_goal.txt
├── events/
│   ├── cfc_events.txt
│   └── cfc_vanilla_overrides.txt
├── docs/
│   └── vanilla-analysis.md
└── localisation/
    ├── english/cfc_l_english.yml
    └── spanish/cfc_l_spanish.yml
```

## Compatibilidad comprobada

- Stellaris **Pegasus 4.4.6 (fdde)**, Steam build **24109497**.
- DLC requerido: **The Machine Age** (`dlc032_machine_age`).
- `supported_version`: `4.4.6` (coincide exactamente con la versión validada
  para evitar avisos incorrectos del launcher con patrones wildcard).

El análisis y el código se hicieron contra los archivos instalados en:

`/disk/sd_tb101/ignacio.garcia/steam_storage/steamapps/common/Stellaris`

La relación concisa de archivos, eventos, efectos y puntos de integración
vanilla está en [`docs/vanilla-analysis.md`](docs/vanilla-analysis.md). El
repositorio no contiene archivos completos ni recursos de la instalación.

## Qué cambia

Durante la fase anterior a `crisis.8043`:

1. Elimina sólo los dos bonus de `queen_combat_modifier` que dan a Cetana
   `+200 %` de daño contra FE y AE. Conserva velocidad, regeneración,
   agotamiento, bombardeo, escalado y bonus contra las demás crisis.
2. Neutraliza y retira `beset_by_cetana` (`-90 %` de daño FE/AE contra Cetana).
3. Sustituye `crisis.8042`, que en vanilla destruye el 80 % de una flota FE y
   después colonias. El reemplazo sólo sanea el estado y no se reprograma.
4. Da protección contra la tormenta a FE/AE para que `crisis.8024` no expulse o
   destruya sus flotas antes del combate.
5. Añade un objetivo de guerra total de intervención. El contacto diplomático
   de Cetana entre sus discursos (`crisis.8063`) ofrece **Intervenir contra
   Cetana**. Sólo quien lo elige entra en guerra y recibe las flags vanilla que
   permiten atravesar la tormenta y evitan que `crisis.8065` deshaga el combate.
6. Detecta la destrucción temprana del titán mediante el mismo
   `on_ship_destroyed_perp` que usa vanilla. El mod bloquea la transición tardía
   y sanea el estado de la fase; **`crisis.23015` vanilla sigue siendo quien
   ejecuta la derrota definitiva** (`end_crisis`, trackers de All Crises,
   recompensas, flags y cadena `crisis.23005/23010`).
7. Normaliza saves nuevos o cargados al inicio/carga y, como respaldo para
   multijugador, en el pulso mensual. Sólo escribe logs cuando cambia una fase o
   un país necesita normalización.

## Qué no cambia

- Aparición y creación vanilla (`crisis.8005` / `synth_queen_spawn`).
- Potencia base, regeneración, velocidad, flotas, diseños o escalado de crisis.
- Bonus de Cetana contra Contingencia, Prethoryn o extradimensionales.
- Guerra automática: ningún imperio normal es añadido por el mod.
- Transición vanilla `crisis.8043` si ya no quedan FE/AE.
- Doomclock, situación, investigación, incursiones, guerra final y final normal.
- Otras crisis, sus probabilidades o su escalado.
- Comportamiento general de FE/AE fuera de la fase de Cetana.

## Archivos vanilla sustituidos por clave/ID

No se modifica ningún archivo de la instalación. El mod reemplaza únicamente:

- `queen_combat_modifier` y `beset_by_cetana`, originalmente en
  `common/static_modifiers/22_static_modifiers_machine_age.txt`.
- `crisis.8042` y `crisis.8063`, originalmente en
  `events/machine_age_crisis_events.txt`.

Los on_actions son aditivos y el resto de claves usa el prefijo `cfc_` o el
namespace `cfc`.

## Saves existentes

Se puede activar con seguridad:

- antes de que aparezca Cetana;
- durante la aparición temprana;
- durante la guerra FE/AE, incluso si `beset_by_cetana`, la tormenta o
  `queen_combat_modifier` ya están aplicados.

Las definiciones nuevas corrigen inmediatamente los valores de modificadores ya
existentes. El normalizador elimina `beset_by_cetana`, la niebla y los
modificadores de tormenta FE/AE sin crear otro país ni volver a disparar eventos.

No se recomienda activarlo después de `synth_queen_speech_2_happened`: para
entonces la fase objetivo ya terminó y el mod deliberadamente no reescribe el
estado histórico. Sí puede dejarse activo para completar la crisis normalmente.

Desactivarlo en mitad de la guerra temprana no restaura automáticamente flags
ya aplicadas al save. Lo más seguro es conservarlo hasta que Cetana gane esa fase
o hasta que su derrota haya terminado por completo.

## Instalación manual

Copiar:

- la carpeta `cetana_fair_crisis` a
  `~/.local/share/Paradox Interactive/Stellaris/mod/cetana_fair_crisis`;
- `cetana_fair_crisis.mod` a
  `~/.local/share/Paradox Interactive/Stellaris/mod/cetana_fair_crisis.mod`.

Después, añadir **Cetana Fair Crisis** a un playset y activarlo. Si otro mod
redefine los mismos modificadores o eventos, colocar éste después de ese mod.

Usar un mod cambia el checksum y normalmente deshabilita logros en esa partida.

## Logging

Buscar `[Cetana Fair Crisis]` en `game.log`. Se registran:

- detección de la fase FE/AE;
- normalización de cada FE/AE una sola vez;
- entrada voluntaria de un imperio;
- destrucción temprana del titán;
- confirmación de cleanup tras las flags vanilla;
- retorno a la cadena vanilla si Cetana gana.

## Plan de pruebas reproducible

Para todos los casos, iniciar Stellaris con `-debug_mode`, activar `game.log` y
guardar antes de la primera conversación de Cetana. Comprobar al final que
`error.log` no contiene errores `cfc`, y que `game.log` muestra sólo las
transiciones esperadas.

### A — Cetana vence a todos los FE/AE

1. No intervenir.
2. Observar combates y esperar a que desaparezca el último FE/AE.
3. Verificar `synth_queen_speech_2_happened`, doomclock y situación visible.
4. Esperado: log de retorno a vanilla; cadena `crisis.8043` normal.

### B — Un FE/AE destruye a Cetana

1. Dejar que la guerra se resuelva sin intervención.
2. Si el FE/AE destruye el titán, aceptar el evento vanilla de victoria.
3. Verificar `synth_queen_defeated`, ausencia de `synth_queen_ongoing`, fin de
   crisis y ausencia de daño FE programado meses después.

### C — El jugador interviene y destruye a Cetana

1. Abrir Diplomacia con Cetana antes del segundo discurso.
2. Elegir **Intervenir contra Cetana**.
3. Confirmar que sólo participantes voluntarios/aliados están en guerra, que la
   tormenta deja pasar sus flotas y que `crisis.8065` no las expulsa.
4. Destruir el titán y repetir las comprobaciones de B.

### D — El jugador no interviene

1. Cerrar el contacto sin elegir intervención.
2. Verificar que el jugador no está en guerra y que sólo FE/AE combaten.

### E — Victoria posterior vanilla

1. Dejar que Cetana gane A.
2. Completar investigación/situación y destruir el titán en la guerra final.
3. Esperado: comportamiento y recompensas vanilla, sin rama temprana del mod.

### F — All Crises y derrota temprana

1. Iniciar con `All Crises` y derrotar tempranamente a Cetana.
2. Confirmar que `galactic_crisis_recently_fired` se elimina, que los trackers
   tempranos se consumen como en `crisis.23015` y que otra crisis puede aparecer.

### G — Cargar durante la guerra FE/AE

1. Guardar con `beset_by_cetana`/tormenta ya presentes y cerrar el juego.
2. Activar el mod y cargar.
3. Esperar como máximo un pulso mensual (multijugador) o ninguno en un save SP.
4. Confirmar normalización sin nueva Cetana, sin reinicio y sin repetir discursos.

## Riesgos e incompatibilidades

- Conflicto directo con mods que redefinan `queen_combat_modifier`,
  `beset_by_cetana`, `crisis.8042` o `crisis.8063`; prevalece el último cargado.
- Una actualización que cambie esos cuatro bloques exige comparar de nuevo el
  mod con vanilla. Por eso la compatibilidad declarada se limita a 4.4.x.
- Stellaris no ofrece una operación de script general para cancelar eventos de
  país ya encolados. El reemplazo de `crisis.8042` es intencionado: las llamadas
  antiguas llegan al reemplazo inocuo, limpian una vez y dejan de reprogramarse.
- La validación automatizada comprueba estructura, llaves, codificación y
  referencias conocidas. Los escenarios A–G requieren simulación dentro del
  juego; no existe un runner headless determinista para esta cadena narrativa.

## Validación realizada

- Balance estructural de llaves en todos los scripts.
- Localizaciones inglesa y española en UTF-8 con BOM.
- Identificadores contrastados con los scripts vanilla de Stellaris 4.4.6.
- Auditoría para confirmar que el mod no contiene `kill_country`, destrucción de
  naves ni destrucción de colonias.
- Comparación por checksum entre el código fuente preparado y la instalación
  manual del mod.
- Comprobación específica del orden de eventos cuando un FE/AE controlado por
  IA destruye el titán antes de que termine la fase inicial.

Esta validación es estática. Los escenarios A–G deben completarse dentro del
juego antes de considerar certificada una versión para publicación pública.

## Desinstalación

1. Llegar primero a un save posterior a la victoria de Cetana en la fase FE/AE,
   o posterior al cleanup completo de su derrota.
2. Desactivar el mod en el playset.
3. Eliminar la carpeta y el archivo `.mod` indicados en Instalación manual.
4. Conservar una copia del save anterior. No desinstalar durante el combate
   inicial si se pretende continuar ese mismo save sin flags residuales.
