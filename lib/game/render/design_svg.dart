// Isi <svg> komponen desain, disalin apa adanya dari docs/design/source/
// (termasuk blok sc-if dan {{nama}}). Jangan disunting dengan tangan: salin
// ulang dari desain kalau desainnya berubah.
// test/game/render/design_sync_test.dart memastikan isinya masih sama.

/// Petak 50×50 (`Tile.dc.html`).
const tileSvg = r'''
  <sc-if value="{{hasFloor}}" hint-placeholder-val="{{ true }}">
    <rect x="0" y="0" width="50" height="50" fill="{{floorFill}}"></rect>
    <rect x="0.5" y="0.5" width="49" height="49" fill="none" stroke="#E6CFA6" stroke-width="1"></rect>
  </sc-if>

  <sc-if value="{{isWallish}}" hint-placeholder-val="{{ false }}">
    <rect x="0" y="0" width="50" height="50" fill="#7E5233"></rect>
    <rect x="0" y="0" width="50" height="41" fill="#B07A4F"></rect>
    <path d="M0 41 H50" stroke="#5E3B22" stroke-width="2"></path>
  </sc-if>
  <sc-if value="{{isWall}}" hint-placeholder-val="{{ false }}">
    <path d="M0 14 H50 M0 27.5 H50 M18 0 V14 M36 14 V27.5 M12 27.5 V41 M40 27.5 V41" stroke="#946140" stroke-width="1.4"></path>
  </sc-if>
  <sc-if value="{{isCupboard}}" hint-placeholder-val="{{ false }}">
    <rect x="4.5" y="4.5" width="19.5" height="32" rx="2.5" fill="#C99466" stroke="#7E5233" stroke-width="1.5"></rect>
    <rect x="26" y="4.5" width="19.5" height="32" rx="2.5" fill="#C99466" stroke="#7E5233" stroke-width="1.5"></rect>
    <circle cx="20.5" cy="21" r="1.7" fill="#5E3B22"></circle>
    <circle cx="29.5" cy="21" r="1.7" fill="#5E3B22"></circle>
  </sc-if>
  <sc-if value="{{isShelf}}" hint-placeholder-val="{{ false }}">
    <rect x="3" y="22" width="44" height="3.5" rx="1" fill="#6E4529"></rect>
    <rect x="7" y="9" width="9" height="13" rx="2.5" fill="#9ED7C4"></rect>
    <rect x="7" y="7.5" width="9" height="3" rx="1" fill="#5E3B22"></rect>
    <rect x="19" y="12" width="8" height="10" rx="2" fill="#F2C36B"></rect>
    <rect x="30" y="8" width="11" height="14" rx="3" fill="#E7A0A0"></rect>
    <rect x="30" y="6.5" width="11" height="3" rx="1" fill="#5E3B22"></rect>
    <rect x="7" y="29" width="15" height="9" rx="2" fill="#E8D6B8"></rect>
    <rect x="26" y="30" width="16" height="8" rx="2" fill="#D9A066"></rect>
  </sc-if>
  <sc-if value="{{isFridge}}" hint-placeholder-val="{{ false }}">
    <rect x="3" y="1.5" width="44" height="41" rx="5" fill="#EEF3F2" stroke="#BFCDCA" stroke-width="1.5"></rect>
    <path d="M3 16 H47" stroke="#BFCDCA" stroke-width="1.5"></path>
    <rect x="38" y="5" width="3" height="7" rx="1.5" fill="#94A3A0"></rect>
    <rect x="38" y="21" width="3" height="13" rx="1.5" fill="#94A3A0"></rect>
  </sc-if>

  <sc-if value="{{isBowl}}" hint-placeholder-val="{{ false }}">
    <circle cx="25" cy="25" r="21" fill="none" stroke="#2BB5A0" stroke-width="2" stroke-dasharray="4 4" opacity="0.8"></circle>
    <ellipse cx="25" cy="31" rx="17" ry="6" fill="#7A4A1F" opacity="0.15"></ellipse>
    <circle cx="25" cy="25" r="16" fill="#3E9BCB"></circle>
    <circle cx="25" cy="25" r="12" fill="#BFE7F7"></circle>
    <circle cx="21" cy="23" r="2.6" fill="#A0703D"></circle>
    <circle cx="27" cy="21" r="2.4" fill="#B98250"></circle>
    <circle cx="28.5" cy="27.5" r="2.6" fill="#A0703D"></circle>
    <circle cx="22.5" cy="29" r="2.3" fill="#B98250"></circle>
    <circle cx="25" cy="25.5" r="2.2" fill="#8C5E2E"></circle>
  </sc-if>

  <sc-if value="{{isTable}}" hint-placeholder-val="{{ false }}">
    <rect x="8" y="9" width="40" height="38" rx="6" fill="#7A4A1F" opacity="0.18"></rect>
    <rect x="4" y="3.5" width="42" height="40" rx="6" fill="#D9A066" stroke="#A8733F" stroke-width="2"></rect>
    <path d="M10 14 H38 M10 33 H33" stroke="#C48A50" stroke-width="1.4" stroke-linecap="round"></path>
  </sc-if>
  <sc-if value="{{isGlass}}" hint-placeholder-val="{{ false }}">
    <circle cx="25" cy="23" r="9" fill="#CDEBF7" stroke="#5FAED3" stroke-width="2"></circle>
    <circle cx="25" cy="23" r="5.5" fill="#EAF7FC"></circle>
    <path d="M20 19.5 Q22 17.5 24.5 17" stroke="#FFFFFF" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
  </sc-if>
  <sc-if value="{{isVase}}" hint-placeholder-val="{{ false }}">
    <circle cx="25" cy="24" r="11.5" fill="#C2492F"></circle>
    <circle cx="25" cy="24" r="8.5" fill="none" stroke="#E7826A" stroke-width="1.6" stroke-dasharray="3 2.5"></circle>
    <circle cx="25" cy="24" r="5" fill="#6E2414"></circle>
    <ellipse cx="18" cy="15" rx="6" ry="2.6" fill="#5BA96A" transform="rotate(40 18 15)"></ellipse>
    <ellipse cx="32.5" cy="14.5" rx="6" ry="2.6" fill="#6BB37A" transform="rotate(-40 32.5 14.5)"></ellipse>
    <circle cx="25" cy="12.5" r="3.4" fill="#FFC83D" stroke="#E0A100" stroke-width="1"></circle>
  </sc-if>
  <sc-if value="{{isBroken}}" hint-placeholder-val="{{ false }}">
    <path d="M17 17 L24 13 L23 22 Z" fill="#C2492F"></path>
    <path d="M28 20 L35 18 L33 27 Z" fill="#A83B24"></path>
    <path d="M20 26 L26 28 L21 33 Z" fill="#C2492F"></path>
    <ellipse cx="34" cy="33" rx="6" ry="2.6" fill="#5BA96A" transform="rotate(-20 34 33)"></ellipse>
    <path d="M2 46 L7 43 L8 49 Z" fill="#C2492F"></path>
    <path d="M42 46 L47 44 L46 49 Z" fill="#A83B24"></path>
  </sc-if>

  <sc-if value="{{itemFish}}" hint-placeholder-val="{{ false }}">
    <ellipse cx="25" cy="31" rx="16" ry="5" fill="#7A4A1F" opacity="0.14"></ellipse>
    <g transform="rotate(-24 25 25)">
      <sc-if value="{{player}}" hint-placeholder-val="{{ false }}">
        <path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z M34 25 L43 18 L42 32 Z" fill="#F28C28" stroke="#F28C28" stroke-width="6" stroke-linejoin="round"></path>
      </sc-if>
      <path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path>
      <path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1" opacity="0.8"></path>
      <circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle>
    </g>
  </sc-if>

  <sc-if value="{{itemWater}}" hint-placeholder-val="{{ false }}">
    <path d="M8 26 C7 16 19 10 27 13 C36 8 45 18 42 27 C45 37 33 43 25 40 C15 44 6 36 8 26 Z" fill="#8FD3F0" stroke="#4FA9D6" stroke-width="1.5"></path>
    <ellipse cx="19" cy="21" rx="5" ry="2" fill="#FFFFFF" opacity="0.75"></ellipse>
    <ellipse cx="31" cy="31" rx="3" ry="1.3" fill="#FFFFFF" opacity="0.6"></ellipse>
  </sc-if>

  <sc-if value="{{itemBucket}}" hint-placeholder-val="{{ false }}">
    <ellipse cx="26" cy="31" rx="17" ry="6" fill="#7A4A1F" opacity="0.16"></ellipse>
    <circle cx="25" cy="25" r="18" fill="none" stroke="#F28C28" stroke-width="3.5"></circle>
    <circle cx="25" cy="25" r="15" fill="#2F86B8"></circle>
    <circle cx="25" cy="25" r="11.5" fill="#8FD3F0"></circle>
    <path d="M17 26 Q21 23 25 26 T33 26" stroke="#FFFFFF" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
    <path d="M10 25 Q25 3 40 25" stroke="#1F5E80" stroke-width="2.4" fill="none"></path>
  </sc-if>

  <sc-if value="{{itemBox}}" hint-placeholder-val="{{ false }}">
    <ellipse cx="27" cy="38" rx="18" ry="5" fill="#7A4A1F" opacity="0.15"></ellipse>
    <sc-if value="{{player}}" hint-placeholder-val="{{ false }}">
      <rect x="4.5" y="4.5" width="41" height="41" rx="5" fill="none" stroke="#F28C28" stroke-width="3.5"></rect>
    </sc-if>
    <rect x="8" y="8" width="34" height="34" rx="2.5" fill="#C8955A" stroke="#9E6C37" stroke-width="1.5"></rect>
    <rect x="13" y="13" width="24" height="24" rx="1.5" fill="#7E5228"></rect>
    <path d="M8 8 L13 13 L37 13 L42 8 Z M8 42 L13 37 L37 37 L42 42 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1" stroke-linejoin="round"></path>
  </sc-if>

  <sc-if value="{{glow}}" hint-placeholder-val="{{ false }}">
    <rect x="2.5" y="2.5" width="45" height="45" rx="8" fill="#F59A33" fill-opacity="0.28" stroke="#E07A10" stroke-width="2.5" stroke-dasharray="5 4" style="animation: koGlow 1s ease-in-out infinite"></rect>
  </sc-if>
''';

/// Oyen, viewBox 100×100 (`Oyen.dc.html`).
const oyenSvg = r'''
  <g transform="{{flipT}}">
    <sc-if value="{{notSleep}}" hint-placeholder-val="{{ true }}">
      <ellipse cx="50" cy="92" rx="31" ry="6.5" fill="#7A4A1F" opacity="0.16"></ellipse>
    </sc-if>

    <sc-if value="{{isBox}}" hint-placeholder-val="{{ false }}">
      <rect x="12" y="44" width="76" height="20" rx="3" fill="#7E5228"></rect>
    </sc-if>

    <sc-if value="{{showTailSide}}" hint-placeholder-val="{{ true }}">
      <path d="{{tailD}}" stroke="#E8892B" stroke-width="11" fill="none" stroke-linecap="round"></path>
      <path d="{{tailTipD}}" stroke="#C4651A" stroke-width="11" fill="none" stroke-linecap="round"></path>
    </sc-if>

    <sc-if value="{{isKnock}}" hint-placeholder-val="{{ false }}">
      <path d="M68 68 Q82 62 88 52" stroke="#F29A3A" stroke-width="12" fill="none" stroke-linecap="round"></path>
      <ellipse cx="89" cy="50" rx="8" ry="6.5" fill="#FBD9A8"></ellipse>
      <path d="M97 38 L101 33 M99 48 L105 47" stroke="#3A2618" stroke-width="2" stroke-linecap="round" opacity="0.6"></path>
    </sc-if>

    <sc-if value="{{isNormal}}" hint-placeholder-val="{{ true }}">
      <ellipse cx="50" cy="{{bodyY}}" rx="27" ry="20" fill="#F29A3A"></ellipse>
      <sc-if value="{{front}}" hint-placeholder-val="{{ true }}">
        <ellipse cx="50" cy="{{bellyY}}" rx="14" ry="10" fill="#FBD9A8"></ellipse>
        <path d="M25 68 L31 70 M24 75 L30 76 M75 68 L69 70 M76 75 L70 76" stroke="#C4651A" stroke-width="2.6" stroke-linecap="round"></path>
      </sc-if>
      <sc-if value="{{back}}" hint-placeholder-val="{{ false }}">
        <path d="M30 64 Q50 58 70 64 M27 72 Q50 66 73 72 M31 80 Q50 75 69 80" stroke="#C4651A" stroke-width="3" fill="none" stroke-linecap="round"></path>
      </sc-if>
      <sc-if value="{{showSarung}}" hint-placeholder-val="{{ false }}">
        <path d="M23 70 Q50 61 77 70 L76 85 Q50 94 24 85 Z" fill="#2F7F8A"></path>
        <path d="M35 66 L33 89 M50 63.5 L50 91.5 M65 66 L67 89 M23.5 77.5 Q50 69.5 76.5 77.5" stroke="#BFE6E0" stroke-width="1.6" fill="none" opacity="0.75"></path>
        <path d="M23 70 Q50 61 77 70" stroke="#1F5E66" stroke-width="2.4" fill="none"></path>
      </sc-if>
      <ellipse cx="39" cy="{{pawL}}" rx="7" ry="5" fill="#FBD9A8"></ellipse>
      <ellipse cx="61" cy="{{pawR}}" rx="7" ry="5" fill="#FBD9A8"></ellipse>
    </sc-if>

    <sc-if value="{{notSleep}}" hint-placeholder-val="{{ true }}">
      <g transform="{{headT}}">
        <path d="M21 38 L23 11 L45 25 Z" fill="#F29A3A" stroke="#F29A3A" stroke-width="4" stroke-linejoin="round"></path>
        <path d="M79 38 L77 11 L55 25 Z" fill="#F29A3A" stroke="#F29A3A" stroke-width="4" stroke-linejoin="round"></path>
        <sc-if value="{{front}}" hint-placeholder-val="{{ true }}">
          <path d="M26 32 L27.5 18 L39 26 Z" fill="#F7B98A" stroke="#F7B98A" stroke-width="2" stroke-linejoin="round"></path>
          <path d="M74 32 L72.5 18 L61 26 Z" fill="#F7B98A" stroke="#F7B98A" stroke-width="2" stroke-linejoin="round"></path>
        </sc-if>
        <ellipse cx="50" cy="42" rx="31" ry="25" fill="#F5A447"></ellipse>
        <ellipse cx="50" cy="51" rx="33.5" ry="16" fill="#F5A447"></ellipse>
        <path d="M43 19 L45 28 M50 17.5 L50 28 M57 19 L55 28" stroke="#C4651A" stroke-width="3.2" stroke-linecap="round"></path>
        <path d="M19 38 L27 40 M18 45 L26 45 M81 38 L73 40 M82 45 L74 45" stroke="#C4651A" stroke-width="2.8" stroke-linecap="round"></path>

        <sc-if value="{{back}}" hint-placeholder-val="{{ false }}">
          <path d="M30 33 Q50 27 70 33 M27 43 Q50 37 73 43 M31 54 Q50 49 69 54" stroke="#C4651A" stroke-width="3" fill="none" stroke-linecap="round"></path>
        </sc-if>

        <sc-if value="{{front}}" hint-placeholder-val="{{ true }}">
          <g transform="{{faceT}}">
            <ellipse cx="50" cy="56" rx="11" ry="7.5" fill="#FDE6C4"></ellipse>
            <ellipse cx="26" cy="55" rx="6" ry="3.5" fill="#F07F6A" opacity="0.45"></ellipse>
            <ellipse cx="74" cy="55" rx="6" ry="3.5" fill="#F07F6A" opacity="0.45"></ellipse>

            <sc-if value="{{eyeSleepy}}" hint-placeholder-val="{{ true }}">
              <path d="M28.5 42 A8.5 8.5 0 0 0 45.5 42 Z" fill="#3A2618"></path>
              <path d="M54.5 42 A8.5 8.5 0 0 0 71.5 42 Z" fill="#3A2618"></path>
              <circle cx="40.5" cy="45" r="2.1" fill="#FFFFFF"></circle>
              <circle cx="66.5" cy="45" r="2.1" fill="#FFFFFF"></circle>
              <circle cx="34" cy="47.2" r="1" fill="#FFFFFF"></circle>
              <circle cx="60" cy="47.2" r="1" fill="#FFFFFF"></circle>
              <path d="M27.5 41.5 L46.5 41.5 M53.5 41.5 L72.5 41.5" stroke="#3A2618" stroke-width="2.6" stroke-linecap="round"></path>
            </sc-if>
            <sc-if value="{{eyeWide}}" hint-placeholder-val="{{ false }}">
              <circle cx="37" cy="42" r="9" fill="#FFFDF7" stroke="#3A2618" stroke-width="2"></circle>
              <circle cx="63" cy="42" r="9" fill="#FFFDF7" stroke="#3A2618" stroke-width="2"></circle>
              <circle cx="37" cy="43" r="3.4" fill="#3A2618"></circle>
              <circle cx="63" cy="43" r="3.4" fill="#3A2618"></circle>
            </sc-if>
            <sc-if value="{{eyeClosed}}" hint-placeholder-val="{{ false }}">
              <path d="M29 43 Q37 49 45 43 M55 43 Q63 49 71 43" stroke="#3A2618" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
            </sc-if>
            <sc-if value="{{eyeHappy}}" hint-placeholder-val="{{ false }}">
              <path d="M29 46 Q37 37 45 46 M55 46 Q63 37 71 46" stroke="#3A2618" stroke-width="2.8" fill="none" stroke-linecap="round"></path>
            </sc-if>

            <path d="M47 51.5 L53 51.5 L50 55 Z" fill="#D9606A" stroke="#D9606A" stroke-width="1.5" stroke-linejoin="round"></path>
            <sc-if value="{{mouthW}}" hint-placeholder-val="{{ true }}">
              <path d="M45 58 Q47.5 61 50 58 Q52.5 61 55 58" stroke="#3A2618" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
            </sc-if>
            <sc-if value="{{mouthO}}" hint-placeholder-val="{{ false }}">
              <ellipse cx="50" cy="60" rx="3.2" ry="3.8" fill="#3A2618"></ellipse>
            </sc-if>
            <sc-if value="{{mouthOpen}}" hint-placeholder-val="{{ false }}">
              <path d="M44.5 57.5 Q50 66 55.5 57.5 Z" fill="#8E3B2E" stroke="#3A2618" stroke-width="1.4" stroke-linejoin="round"></path>
            </sc-if>
            <path d="M37 56 L24 54 M37 59 L25 61 M63 56 L76 54 M63 59 L75 61" stroke="#3A2618" stroke-width="1.1" opacity="0.45" stroke-linecap="round"></path>
          </g>
        </sc-if>

        <sc-if value="{{showPeci}}" hint-placeholder-val="{{ false }}">
          <path d="M31 27 L32.5 15 Q50 8 67.5 15 L69 27 Q50 22.5 31 27 Z" fill="#2B2A33"></path>
          <path d="M33 23 Q50 18.5 67 23" stroke="#5A5870" stroke-width="1.5" fill="none"></path>
        </sc-if>
        <sc-if value="{{showKoki}}" hint-placeholder-val="{{ false }}">
          <path d="M33 25 L33 12 Q24 6 31 -1 Q37 -9 46 -4 Q51 -11 58 -4 Q67 -8 70 0 Q76 7 67 12 L67 25 Q50 21 33 25 Z" fill="#FFFFFF" stroke="#D9CBB5" stroke-width="1.6" stroke-linejoin="round"></path>
          <path d="M33 18 Q50 14 67 18" stroke="#D9CBB5" stroke-width="1.4" fill="none"></path>
        </sc-if>
        <sc-if value="{{showGlasses}}" hint-placeholder-val="{{ false }}">
          <g transform="{{faceT}}">
            <circle cx="37" cy="43" r="10.5" fill="#FFFFFF" fill-opacity="0.18" stroke="#3A2618" stroke-width="2.4"></circle>
            <circle cx="63" cy="43" r="10.5" fill="#FFFFFF" fill-opacity="0.18" stroke="#3A2618" stroke-width="2.4"></circle>
            <path d="M47.5 42 Q50 39.5 52.5 42 M26.5 41 L19 38.5 M73.5 41 L81 38.5" stroke="#3A2618" stroke-width="2.2" fill="none" stroke-linecap="round"></path>
          </g>
        </sc-if>
      </g>
    </sc-if>

    <sc-if value="{{showTailBack}}" hint-placeholder-val="{{ false }}">
      <path d="M50 86 C50 102 70 104 76 94" stroke="#E8892B" stroke-width="11" fill="none" stroke-linecap="round"></path>
      <path d="M55 99 L59 94.5 M65 102 L67 96.5" stroke="#C4651A" stroke-width="2.6" stroke-linecap="round"></path>
    </sc-if>

    <sc-if value="{{isBox}}" hint-placeholder-val="{{ false }}">
      <rect x="10" y="58" width="80" height="36" rx="3" fill="#C8955A"></rect>
      <path d="M10 58 L0 47 L21 45 L28 58 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M90 58 L100 47 L79 45 L72 58 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1.4" stroke-linejoin="round"></path>
      <rect x="45" y="58" width="10" height="36" fill="#E6C38F"></rect>
      <path d="M10 58 L90 58" stroke="#9E6C37" stroke-width="1.6"></path>
      <ellipse cx="39" cy="59" rx="7" ry="4.5" fill="#FBD9A8"></ellipse>
      <ellipse cx="61" cy="59" rx="7" ry="4.5" fill="#FBD9A8"></ellipse>
    </sc-if>

    <sc-if value="{{isSleep}}" hint-placeholder-val="{{ false }}">
      <ellipse cx="52" cy="86" rx="42" ry="8" fill="#7A4A1F" opacity="0.16"></ellipse>
      <ellipse cx="56" cy="60" rx="38" ry="27" fill="#F29A3A"></ellipse>
      <path d="M44 36 Q48 45 44 54 M58 33.5 Q62 44 58 54 M72 36 Q75 45 71 55 M84 44 Q86 51 82 58" stroke="#C4651A" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
      <path d="M14 52 L13 33 L29 43 Z" fill="#F29A3A" stroke="#F29A3A" stroke-width="3.5" stroke-linejoin="round"></path>
      <path d="M43 44 L52 31 L56 48 Z" fill="#F29A3A" stroke="#F29A3A" stroke-width="3.5" stroke-linejoin="round"></path>
      <path d="M17 47 L16.5 38 L24 43 Z" fill="#F7B98A"></path>
      <ellipse cx="34" cy="61" rx="24" ry="18" fill="#F5A447"></ellipse>
      <ellipse cx="34" cy="66" rx="26" ry="13" fill="#F5A447"></ellipse>
      <path d="M28 46 L30 52 M34 45 L34 52 M40 46 L38 52" stroke="#C4651A" stroke-width="2.8" stroke-linecap="round"></path>
      <ellipse cx="34" cy="70" rx="7.5" ry="4.8" fill="#FDE6C4"></ellipse>
      <ellipse cx="16" cy="67" rx="5" ry="3" fill="#F07F6A" opacity="0.45"></ellipse>
      <ellipse cx="52" cy="67" rx="5" ry="3" fill="#F07F6A" opacity="0.45"></ellipse>
      <path d="M19 62 Q25 67 31 62 M37 62 Q43 67 49 62" stroke="#3A2618" stroke-width="2.4" fill="none" stroke-linecap="round"></path>
      <path d="M32 67.5 L36 67.5 L34 70 Z" fill="#D9606A" stroke="#D9606A" stroke-width="1.2" stroke-linejoin="round"></path>
      <path d="M92 62 C98 86 62 96 26 88" stroke="#E8892B" stroke-width="11" fill="none" stroke-linecap="round"></path>
      <path d="M30 89 C28 88.5 27 88.3 26 88" stroke="#C4651A" stroke-width="11" fill="none" stroke-linecap="round"></path>
      <path d="M76 88 L74 82 M88 80 L84 76" stroke="#C4651A" stroke-width="2.6" stroke-linecap="round"></path>
    </sc-if>

    <sc-if value="{{isShock}}" hint-placeholder-val="{{ false }}">
      <path d="M27 8 L22 1 M50 4 L50 -4 M73 8 L78 1" stroke="#3A2618" stroke-width="2.4" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{isEat}}" hint-placeholder-val="{{ false }}">
      <circle cx="43" cy="74" r="1.6" fill="#9E6C37"></circle>
      <circle cx="58" cy="75" r="1.4" fill="#9E6C37"></circle>
      <circle cx="51" cy="77" r="1.2" fill="#9E6C37"></circle>
    </sc-if>
  </g>

  <sc-if value="{{isHappy}}" hint-placeholder-val="{{ false }}">
    <path d="M8 14 L9.8 19.2 L15 21 L9.8 22.8 L8 28 L6.2 22.8 L1 21 L6.2 19.2 Z" fill="#FFC83D"></path>
    <path d="M92 6 L93.4 10.6 L98 12 L93.4 13.4 L92 18 L90.6 13.4 L86 12 L90.6 10.6 Z" fill="#FFC83D"></path>
    <path d="M98 40 L99 43 L102 44 L99 45 L98 48 L97 45 L94 44 L97 43 Z" fill="#FFC83D"></path>
  </sc-if>
  <sc-if value="{{showZzz}}" hint-placeholder-val="{{ false }}">
    <g transform="{{zzzT}}" fill="#2F86B8" font-family="Fredoka, sans-serif" font-weight="700">
      <text x="80" y="16" font-size="18">Z</text>
      <text x="94" y="3" font-size="13">z</text>
      <text x="104" y="-7" font-size="9">z</text>
    </g>
  </sc-if>
  <sc-if value="{{showKaget}}" hint-placeholder-val="{{ false }}">
    <circle cx="76" cy="12" r="2.6" fill="#FFFFFF" stroke="#3A2618" stroke-width="1.6"></circle>
    <circle cx="83" cy="3" r="3.8" fill="#FFFFFF" stroke="#3A2618" stroke-width="1.6"></circle>
    <circle cx="98" cy="-12" r="13.5" fill="#FFFFFF" stroke="#3A2618" stroke-width="2"></circle>
    <text x="98" y="-5" text-anchor="middle" font-size="20" font-weight="700" fill="#C2492F" font-family="Fredoka, sans-serif">!</text>
  </sc-if>
''';

/// Panah arah hadap 12×12 di papan (`Board.dc.html`).
const facingSvg = r'''
<path d="M3 2 L9 6 L3 10" fill="none" stroke="#3B2716" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"></path>
''';

/// Ikan asin di slot baki (`03-gameplay-fase-atur.html`), viewBox 50×50.
const trayFishSvg = r'''
<g transform="rotate(-24 25 25)"><path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z M34 25 L43 18 L42 32 Z" fill="#F28C28" stroke="#F28C28" stroke-width="6" stroke-linejoin="round"></path><path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path><path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path><path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1"></path><circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle></g>
''';

/// Ember air yang sedang diseret (`03-gameplay-fase-atur.html`), viewBox
/// 50×50. Dipakai juga untuk ember di slot baki, yang tidak ada di desain.
const trayBucketSvg = r'''
      <circle cx="25" cy="25" r="18" fill="#FFFBF3" stroke="#F28C28" stroke-width="3.5"></circle>
      <circle cx="25" cy="25" r="15" fill="#2F86B8"></circle>
      <circle cx="25" cy="25" r="11.5" fill="#8FD3F0"></circle>
      <path d="M17 26 Q21 23 25 26 T33 26" stroke="#FFFFFF" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
      <path d="M10 25 Q25 3 40 25" stroke="#1F5E80" stroke-width="2.4" fill="none"></path>
''';

/// Bayangan ember di slot baki yang sisanya 0
/// (`03-gameplay-fase-atur.html`), viewBox 50×50.
const trayBucketGhostSvg = r'''
<circle cx="25" cy="25" r="15" fill="#2F86B8"></circle><circle cx="25" cy="25" r="11.5" fill="#8FD3F0"></circle><path d="M10 25 Q25 3 40 25" stroke="#1F5E80" stroke-width="2.4" fill="none"></path>
''';

/// Kardus di slot baki: blok kardus `Tile.dc.html` tanpa bayangan lantai
/// (baris `<ellipse>` pertama), seperti ikan dan ember di slot desain 03.
/// `{{player}}` true = cincin oranye benda pemain.
const trayBoxSvg = r'''
    <sc-if value="{{player}}" hint-placeholder-val="{{ false }}">
      <rect x="4.5" y="4.5" width="41" height="41" rx="5" fill="none" stroke="#F28C28" stroke-width="3.5"></rect>
    </sc-if>
    <rect x="8" y="8" width="34" height="34" rx="2.5" fill="#C8955A" stroke="#9E6C37" stroke-width="1.5"></rect>
    <rect x="13" y="13" width="24" height="24" rx="1.5" fill="#7E5228"></rect>
    <path d="M8 8 L13 13 L37 13 L42 8 Z M8 42 L13 37 L37 37 L42 42 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1" stroke-linejoin="round"></path>
''';

/// Bayangan ikan di slot baki yang sisanya 0: [trayFishSvg] tanpa cincin
/// oranye, mengikuti bayangan ember. Tidak ada di desain.
const trayFishGhostSvg = r'''
<g transform="rotate(-24 25 25)"><path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path><path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path><path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1"></path><circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle></g>
''';

/// Gelembung pikiran ikan di atas Oyen, viewBox 100×100 seperti
/// [oyenSvg]. Tidak ada di desain (GDD: gelembung menunjukkan incaran
/// Oyen): lingkaran gelembung kaget `Oyen.dc.html` dengan ikan asin
/// `Tile.dc.html` (tanpa bayangan dan cincin pemain) diperkecil di dalamnya.
const fishBubbleSvg = r'''
<circle cx="76" cy="12" r="2.6" fill="#FFFFFF" stroke="#3A2618" stroke-width="1.6"></circle>
<circle cx="83" cy="3" r="3.8" fill="#FFFFFF" stroke="#3A2618" stroke-width="1.6"></circle>
<circle cx="98" cy="-12" r="13.5" fill="#FFFFFF" stroke="#3A2618" stroke-width="2"></circle>
<g transform="translate(98 -12) scale(0.6) translate(-25.5 -25)">
<g transform="rotate(-24 25 25)">
<path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path>
<path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path>
<path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1" opacity="0.8"></path>
<circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle>
</g>
</g>
''';
