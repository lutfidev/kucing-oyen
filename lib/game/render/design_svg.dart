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

/// Sinar di belakang layar Berhasil (`06-hasil-berhasil.html`), viewBox
/// -310 -310 620 620: dua belas segitiga dari titik tengah.
const raysSvg = r'''
    <g fill="#FCE3BC">
      <path d="M0 0 L-28 -310 L28 -310 Z"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(30)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(60)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(90)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(120)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(150)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(180)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(210)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(240)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(270)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(300)"></path>
      <path d="M0 0 L-28 -310 L28 -310 Z" transform="rotate(330)"></path>
    </g>
''';

/// Mangkuk penuh pakan di layar Berhasil (`06-hasil-berhasil.html`), viewBox
/// 140×54.
const successBowlSvg = r'''
      <ellipse cx="70" cy="46" rx="62" ry="7" fill="#7A4A1F" opacity="0.16"></ellipse>
      <path d="M8 14 H132 L120 44 Q70 54 20 44 Z" fill="#3E9BCB"></path>
      <ellipse cx="70" cy="14" rx="62" ry="10" fill="#2F86B8"></ellipse>
      <ellipse cx="70" cy="13" rx="54" ry="7" fill="#BFE7F7"></ellipse>
      <circle cx="52" cy="11" r="4" fill="#A0703D"></circle><circle cx="64" cy="13" r="4" fill="#B98250"></circle><circle cx="80" cy="11" r="4" fill="#A0703D"></circle><circle cx="92" cy="14" r="3.5" fill="#8C5E2E"></circle>
      <path d="M26 30 Q70 40 114 30" stroke="#8FD3F0" stroke-width="3" fill="none" stroke-linecap="round"></path>
''';

/// Mangkuk di layar vas pecah (`07-hasil-vas-pecah.html`), viewBox 140×54.
const vaseBowlSvg = r'''
      <ellipse cx="70" cy="46" rx="62" ry="7" fill="#7A4A1F" opacity="0.16"></ellipse>
      <path d="M8 14 H132 L120 44 Q70 54 20 44 Z" fill="#3E9BCB"></path>
      <ellipse cx="70" cy="14" rx="62" ry="10" fill="#2F86B8"></ellipse>
      <ellipse cx="70" cy="13" rx="54" ry="7" fill="#BFE7F7"></ellipse>
      <circle cx="56" cy="11" r="4" fill="#A0703D"></circle><circle cx="72" cy="13" r="4" fill="#B98250"></circle><circle cx="86" cy="11" r="4" fill="#A0703D"></circle>
''';

/// Ilustrasi layar vas pecah (`07-hasil-vas-pecah.html`), viewBox 358×300,
/// dipotong jadi empat bagian karena dua di antaranya bergerak. Urutan
/// gambar: dinding dan pintu, Ibu ([vaseMomSvg], geser masuk `koPeek`), meja
/// dengan pecahan vas, lalu "PRANG!" ([vasePrangSvg], goyang `koShake`).
const vaseRoomSvg = r'''
      <rect x="0" y="0" width="358" height="64" fill="#E9C9A0"></rect>
      <rect x="0" y="58" width="358" height="8" fill="#B07A4F"></rect>

      <rect x="250" y="8" width="96" height="164" rx="4" fill="#8A5A3B"></rect>
      <rect x="259" y="17" width="78" height="155" fill="#4A2F1C"></rect>
''';

/// Ibu yang muncul dari pintu dengan wajah kesal (grup `koPeek`).
const vaseMomSvg = r'''
        <rect x="274" y="96" width="58" height="80" rx="18" fill="#4F8A8B"></rect>
        <path d="M290 100 L303 116 L316 100" fill="none" stroke="#3B6C6D" stroke-width="3" stroke-linejoin="round"></path>
        <circle cx="303" cy="70" r="24" fill="#F0C29E"></circle>
        <path d="M279 70 Q281 42 303 44 Q325 42 327 70 Q321 55 303 55 Q285 55 279 70 Z" fill="#3B2716"></path>
        <circle cx="303" cy="38" r="11" fill="#3B2716"></circle>
        <path d="M290 63 L299 67 M316 63 L307 67" stroke="#3B2716" stroke-width="3" stroke-linecap="round"></path>
        <circle cx="295" cy="73" r="2.5" fill="#3B2716"></circle>
        <circle cx="311" cy="73" r="2.5" fill="#3B2716"></circle>
        <path d="M296 85 Q303 80 310 85" stroke="#3B2716" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
        <ellipse cx="287" cy="80" rx="4" ry="2.4" fill="#E58C7A" opacity="0.5"></ellipse>
        <ellipse cx="319" cy="80" rx="4" ry="2.4" fill="#E58C7A" opacity="0.5"></ellipse>
        <ellipse cx="262" cy="118" rx="8" ry="10" fill="#F0C29E"></ellipse>
        <path d="M330 44 Q334 48 330 52 M338 44 Q334 48 338 52 M327 47 Q331 51 335 47 M327 55 Q331 51 335 55" stroke="#C2492F" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
''';

/// Meja, pecahan vas, daun, dan koin di lantai.
const vaseTableSvg = r'''
      <rect x="34" y="112" width="96" height="74" rx="12" fill="#7A4A1F" opacity="0.16"></rect>
      <rect x="28" y="104" width="96" height="74" rx="12" fill="#D9A066" stroke="#A8733F" stroke-width="2.5"></rect>
      <path d="M40 124 H104 M40 156 H92" stroke="#C48A50" stroke-width="2" stroke-linecap="round"></path>
      <path d="M60 128 L72 120 L70 138 Z" fill="#C2492F"></path>
      <path d="M80 136 L94 132 L90 148 Z" fill="#A83B24"></path>
      <path d="M58 150 L70 152 L62 162 Z" fill="#C2492F"></path>
      <path d="M22 196 L32 190 L34 202 Z" fill="#C2492F"></path>
      <path d="M126 192 L138 188 L136 200 Z" fill="#A83B24"></path>
      <path d="M100 206 L108 200 L112 210 Z" fill="#C2492F"></path>
      <ellipse cx="96" cy="160" rx="10" ry="4" fill="#5BA96A" transform="rotate(-20 96 160)"></ellipse>
      <ellipse cx="44" cy="214" rx="9" ry="3.6" fill="#6BB37A" transform="rotate(25 44 214)"></ellipse>
      <circle cx="148" cy="214" r="5" fill="#FFC83D" stroke="#E0A100" stroke-width="1.2"></circle>
''';

/// Ledakan "PRANG!" di sekitar titik (0, 0); desain menaruhnya di
/// `translate(60 76)` dan menggoyangnya (grup `koShake`).
const vasePrangSvg = r'''
        <path d="M0 -26 L8 -12 L24 -18 L16 -4 L30 4 L14 8 L18 24 L4 14 L-6 28 L-8 12 L-26 16 L-14 2 L-28 -8 L-10 -10 L-14 -26 L-2 -16 Z" fill="#FFFBF3" stroke="#C2492F" stroke-width="2.5" stroke-linejoin="round"></path>
        <text x="1" y="6" text-anchor="middle" font-family="Fredoka, sans-serif" font-weight="700" font-size="13" fill="#9A3520">PRANG!</text>
''';

/// Jejak kaki di latar Beranda (`01-beranda.html`), di koordinat layar
/// 390×844. Dipotong dua karena dua jejak bawah menempel ke sudut kiri
/// bawah layar dan dua jejak atas ke sudut kanan atas.
const homePawsBottomSvg = r'''
    <g fill="#E7C796">
      <g transform="translate(46 760) rotate(-20)"><ellipse cx="0" cy="4" rx="7" ry="6"></ellipse><circle cx="-7" cy="-5" r="2.8"></circle><circle cx="-2.5" cy="-9" r="2.8"></circle><circle cx="2.5" cy="-9" r="2.8"></circle><circle cx="7" cy="-5" r="2.8"></circle></g>
      <g transform="translate(78 724) rotate(-10)"><ellipse cx="0" cy="4" rx="7" ry="6"></ellipse><circle cx="-7" cy="-5" r="2.8"></circle><circle cx="-2.5" cy="-9" r="2.8"></circle><circle cx="2.5" cy="-9" r="2.8"></circle><circle cx="7" cy="-5" r="2.8"></circle></g>
    </g>
''';

const homePawsTopSvg = r'''
    <g fill="#E7C796">
      <g transform="translate(330 140) rotate(25)"><ellipse cx="0" cy="4" rx="7" ry="6"></ellipse><circle cx="-7" cy="-5" r="2.8"></circle><circle cx="-2.5" cy="-9" r="2.8"></circle><circle cx="2.5" cy="-9" r="2.8"></circle><circle cx="7" cy="-5" r="2.8"></circle></g>
      <g transform="translate(352 178) rotate(35)"><ellipse cx="0" cy="4" rx="7" ry="6"></ellipse><circle cx="-7" cy="-5" r="2.8"></circle><circle cx="-2.5" cy="-9" r="2.8"></circle><circle cx="2.5" cy="-9" r="2.8"></circle><circle cx="7" cy="-5" r="2.8"></circle></g>
    </g>
''';

/// Ikon Babak 1 – Dapur di kartu babak (`02-peta-babak-2-ruang-tamu.html`),
/// viewBox 36×36: lemari dan mangkuk.
const chapterKitchenSvg = r'''
<rect width="36" height="36" rx="10" fill="#F7E8CE"></rect><rect x="6" y="7" width="24" height="15" rx="2.5" fill="#B07A4F"></rect><rect x="8.5" y="9" width="9" height="11" rx="1.5" fill="#C99466"></rect><rect x="18.5" y="9" width="9" height="11" rx="1.5" fill="#C99466"></rect><circle cx="18" cy="28" r="4.5" fill="#3E9BCB"></circle><circle cx="18" cy="28" r="3" fill="#BFE7F7"></circle>
''';

/// Ikon Babak 2 – Ruang Tamu di kartu babak, viewBox 36×36. Tidak ada di
/// desain (desain 02 hanya punya ikon dapur): latar [chapterKitchenSvg]
/// dengan meja dan vas `Tile.dc.html` diperkecil.
const chapterLivingRoomSvg = r'''
<rect width="36" height="36" rx="10" fill="#F7E8CE"></rect>
<g transform="translate(18 18) scale(0.64) translate(-25 -23.5)">
    <rect x="4" y="3.5" width="42" height="40" rx="6" fill="#D9A066" stroke="#A8733F" stroke-width="2"></rect>
    <path d="M10 14 H38 M10 33 H33" stroke="#C48A50" stroke-width="1.4" stroke-linecap="round"></path>
    <circle cx="25" cy="24" r="11.5" fill="#C2492F"></circle>
    <circle cx="25" cy="24" r="8.5" fill="none" stroke="#E7826A" stroke-width="1.6" stroke-dasharray="3 2.5"></circle>
    <circle cx="25" cy="24" r="5" fill="#6E2414"></circle>
    <ellipse cx="18" cy="15" rx="6" ry="2.6" fill="#5BA96A" transform="rotate(40 18 15)"></ellipse>
    <ellipse cx="32.5" cy="14.5" rx="6" ry="2.6" fill="#6BB37A" transform="rotate(-40 32.5 14.5)"></ellipse>
    <circle cx="25" cy="12.5" r="3.4" fill="#FFC83D" stroke="#E0A100" stroke-width="1"></circle>
</g>
''';

/// Area bos di peta babak (`02-peta-babak-2-ruang-tamu.html`), di
/// koordinat layar 390×844.
const bossAreaSvg = r'''
    <rect x="30" y="626" width="330" height="168" rx="30" fill="#C2492F" opacity="0.16"></rect>
    <rect x="44" y="640" width="302" height="140" rx="22" fill="none" stroke="#C2492F" stroke-width="3" stroke-dasharray="2 9" opacity="0.4"></rect>
''';

/// Ketupat bos Babak 2 "Hari Lebaran" (`02-peta-babak-2-ruang-tamu.html`),
/// viewBox 64×64.
const bossKetupatSvg = r'''
<g opacity="0.8"><path d="M32 6 L54 28 L32 50 L10 28 Z" fill="#7DBE6E" stroke="#3F7A3A" stroke-width="2.4" stroke-linejoin="round"></path><path d="M21 17 L43 39 M43 17 L21 39 M26.5 11.5 L48.5 33.5 M37.5 11.5 L15.5 33.5" stroke="#4E9447" stroke-width="2"></path><path d="M32 50 Q28 56 24 62 M32 50 Q36 56 41 61" stroke="#3F7A3A" stroke-width="2.6" fill="none" stroke-linecap="round"></path></g>
''';

/// Bos Babak 1 "Pesta Ikan Asin", viewBox 64×64. Tidak ada di desain
/// (desain 02 hanya punya ketupat bos Babak 2): sepasang ikan asin
/// `Tile.dc.html` yang berlawanan arah, dengan opasitas grup
/// [bossKetupatSvg].
const bossFishSvg = r'''
<g opacity="0.8">
<g transform="translate(30 23) scale(1.3) translate(-25.5 -25)">
    <g transform="rotate(-24 25 25)">
      <path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path>
      <path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1" opacity="0.8"></path>
      <circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle>
    </g>
</g>
<g transform="translate(34 42) scale(-1.3 1.3) translate(-25.5 -25)">
    <g transform="rotate(-24 25 25)">
      <path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path>
      <path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1" opacity="0.8"></path>
      <circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle>
    </g>
</g>
</g>
''';

// ── Kartu aturan dan tutorial ───────────────────────────────────────────

/// Gambar kartu aturan 1–4 (`05-kartu-aturan-oyen.html`), viewBox 76×76:
/// jatuhkan barang, kejar ikan, air, dan mentok tembok. Kucing kartu 4
/// berputar seperempat (grup `koQuarter`), jadi dipisah ke
/// [ruleWallCatSvg].
const ruleKnockSvg = r'''
<rect width="76" height="76" rx="16" fill="#F7E8CE"></rect><rect x="38" y="10" width="30" height="30" rx="5" fill="#D9A066" stroke="#A8733F" stroke-width="2"></rect><circle cx="53" cy="25" r="7" fill="#CDEBF7" stroke="#5FAED3" stroke-width="2"></circle><path d="M55 44 l4 8 M50 46 l-1 7 M60 41 l7 4" stroke="#C2492F" stroke-width="2.4" stroke-linecap="round"></path><g transform="translate(22 50)"><path d="M-10 -2 L-9 -13 L-2 -8 Z M10 -2 L9 -13 L2 -8 Z" fill="#F29A3A"></path><circle r="10" fill="#F5A447"></circle><path d="M-5 -1 h3.5 M1.5 -1 h3.5" stroke="#3A2618" stroke-width="1.8" stroke-linecap="round"></path></g><path d="M30 38 Q34 30 40 30" stroke="#E07A10" stroke-width="3" fill="none" stroke-linecap="round"></path>
''';

const ruleFishSvg = r'''
<rect width="76" height="76" rx="16" fill="#F7E8CE"></rect>
            <path d="M38 22 V9" stroke="#E07A10" stroke-width="2.6" stroke-linecap="round"></path><path d="M34 12.5 L38 8 L42 12.5" stroke="#E07A10" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
            <path d="M49 25 A17 17 0 0 1 55 43" stroke="#3E9BCB" stroke-width="2.6" fill="none" stroke-linecap="round"></path><path d="M51.5 40 L55 44.5 L58.5 40" stroke="#3E9BCB" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
            <path d="M27 25 A17 17 0 0 0 21 43" stroke="#9A3520" stroke-width="2.6" fill="none" stroke-linecap="round"></path><path d="M17.5 40 L21 44.5 L24.5 40" stroke="#9A3520" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
            <path d="M38 58 V69" stroke="#8A7259" stroke-width="2.6" stroke-linecap="round" stroke-dasharray="1 4"></path><path d="M34 65.5 L38 70 L42 65.5" stroke="#8A7259" stroke-width="2.6" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
            <ellipse cx="38" cy="45" rx="7.5" ry="9.5" fill="#F29A3A"></ellipse><path d="M38 54 Q38 59 42 60" stroke="#E8892B" stroke-width="3.4" fill="none" stroke-linecap="round"></path><path d="M31 32 L31.5 24.5 L36 29 Z M45 32 L44.5 24.5 L40 29 Z" fill="#F29A3A"></path><circle cx="38" cy="34" r="7.5" fill="#F5A447"></circle><path d="M34 33 h2.6 M39.4 33 h2.6" stroke="#3A2618" stroke-width="1.6" stroke-linecap="round"></path>
''';

const ruleWaterSvg = r'''
<rect width="76" height="76" rx="16" fill="#F7E8CE"></rect><path d="M46 26 C44 18 56 13 62 17 C70 15 74 26 68 32 C70 41 58 45 52 41 C44 42 42 33 46 26 Z" fill="#8FD3F0" stroke="#4FA9D6" stroke-width="1.5"></path><g transform="translate(24 30)"><path d="M-10 -2 L-9 -13 L-2 -8 Z M10 -2 L9 -13 L2 -8 Z" fill="#F29A3A"></path><circle r="10" fill="#F5A447"></circle><circle cx="-4" cy="-1" r="2.6" fill="#FFFDF7" stroke="#3A2618" stroke-width="1.2"></circle><circle cx="4" cy="-1" r="2.6" fill="#FFFDF7" stroke="#3A2618" stroke-width="1.2"></circle></g><path d="M38 46 C 38 62, 14 62, 14 52" stroke="#E07A10" stroke-width="3" fill="none" stroke-linecap="round"></path><path d="M9 56 L14 50 L19 56" stroke="#E07A10" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
''';

const ruleWallSvg = r'''
<rect width="76" height="76" rx="16" fill="#F7E8CE"></rect><rect x="56" y="6" width="16" height="64" rx="3" fill="#B07A4F"></rect><path d="M56 27 H72 M56 48 H72" stroke="#946140" stroke-width="1.4"></path>
            <path d="M24 20.7 A20 20 0 1 1 16.7 48" stroke="#E07A10" stroke-width="2.8" fill="none" stroke-linecap="round" stroke-dasharray="1 5.5"></path><path d="M16.2 55.2 L16.7 48 L23.2 51.2" stroke="#E07A10" stroke-width="2.8" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
''';

const ruleWallCatSvg = r'''
              <path d="M28 37 Q22 37 20 33" stroke="#E8892B" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
              <ellipse cx="35" cy="37" rx="9.5" ry="7.5" fill="#F29A3A"></ellipse>
              <path d="M44 30 L51.5 30.5 L47 35 Z M44 44 L51.5 43.5 L47 39 Z" fill="#F29A3A"></path>
              <circle cx="46" cy="37" r="7.5" fill="#F5A447"></circle>
              <path d="M47 33 v2.6 M47 38.4 v2.6" stroke="#3A2618" stroke-width="1.6" stroke-linecap="round"></path>
              <path d="M24 37 L54 37" stroke="none"></path>
''';

/// Kartu kardus terkunci (`05-kartu-aturan-oyen.html`), viewBox 76×76.
const ruleBoxLockedSvg = r'''
<rect width="76" height="76" rx="16" fill="#E6D6BC"></rect><g opacity="0.45"><rect x="18" y="18" width="40" height="40" rx="3" fill="#C8955A" stroke="#9E6C37" stroke-width="1.5"></rect><rect x="24" y="24" width="28" height="28" rx="2" fill="#7E5228"></rect></g><circle cx="38" cy="38" r="15" fill="#3B2716"></circle><rect x="31" y="37" width="14" height="10" rx="2.5" fill="none" stroke="#FFF4E2" stroke-width="2.2"></rect><path d="M34 37v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#FFF4E2" stroke-width="2.2"></path>
''';

/// Kartu kardus terbuka, viewBox 76×76. Tidak ada di desain (desain 05
/// hanya punya kardus terkunci): latar kartu 1, kardus dari
/// [ruleBoxLockedSvg] tanpa pudar, dan kepala Oyen bermata tertutup dari
/// kartu 1 di dalamnya.
const ruleBoxSvg = r'''
<rect width="76" height="76" rx="16" fill="#F7E8CE"></rect><rect x="18" y="18" width="40" height="40" rx="3" fill="#C8955A" stroke="#9E6C37" stroke-width="1.5"></rect><rect x="24" y="24" width="28" height="28" rx="2" fill="#7E5228"></rect>
<g transform="translate(38 41)"><path d="M-10 -2 L-9 -13 L-2 -8 Z M10 -2 L9 -13 L2 -8 Z" fill="#F29A3A"></path><circle r="10" fill="#F5A447"></circle><path d="M-5 -1 h3.5 M1.5 -1 h3.5" stroke="#3A2618" stroke-width="1.8" stroke-linecap="round"></path></g>
''';

/// Kartu 1–4 terkunci, viewBox 76×76. Tidak ada di desain: latar, pudar
/// 0,45, dan gembok [ruleBoxLockedSvg] di atas benda dari gambar kartu
/// terbukanya (meja dan gelas, ikan asin `Tile.dc.html`, genangan, tembok)
/// yang digeser ke tengah.
const ruleKnockLockedSvg = r'''
<rect width="76" height="76" rx="16" fill="#E6D6BC"></rect><g opacity="0.45">
<g transform="translate(-15 13)"><rect x="38" y="10" width="30" height="30" rx="5" fill="#D9A066" stroke="#A8733F" stroke-width="2"></rect><circle cx="53" cy="25" r="7" fill="#CDEBF7" stroke="#5FAED3" stroke-width="2"></circle></g>
</g><circle cx="38" cy="38" r="15" fill="#3B2716"></circle><rect x="31" y="37" width="14" height="10" rx="2.5" fill="none" stroke="#FFF4E2" stroke-width="2.2"></rect><path d="M34 37v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#FFF4E2" stroke-width="2.2"></path>
''';

const ruleFishLockedSvg = r'''
<rect width="76" height="76" rx="16" fill="#E6D6BC"></rect><g opacity="0.45">
<g transform="translate(38 38) scale(1.3) translate(-25.5 -25)">
<g transform="rotate(-24 25 25)">
<path d="M34 25 L43 18 L42 32 Z" fill="#B49C74" stroke="#7E6848" stroke-width="1.4" stroke-linejoin="round"></path>
<path d="M8 25 Q21 13 34 25 Q21 37 8 25 Z" fill="#CDB892" stroke="#7E6848" stroke-width="1.4"></path>
<path d="M19 20.5 V29.5 M24 19.5 V30.5 M29 21 V29" stroke="#8D7656" stroke-width="1.1" opacity="0.8"></path>
<circle cx="13" cy="24" r="1.7" fill="#3A2618"></circle>
</g>
</g>
</g><circle cx="38" cy="38" r="15" fill="#3B2716"></circle><rect x="31" y="37" width="14" height="10" rx="2.5" fill="none" stroke="#FFF4E2" stroke-width="2.2"></rect><path d="M34 37v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#FFF4E2" stroke-width="2.2"></path>
''';

const ruleWaterLockedSvg = r'''
<rect width="76" height="76" rx="16" fill="#E6D6BC"></rect><g opacity="0.45">
<g transform="translate(-20 9)"><path d="M46 26 C44 18 56 13 62 17 C70 15 74 26 68 32 C70 41 58 45 52 41 C44 42 42 33 46 26 Z" fill="#8FD3F0" stroke="#4FA9D6" stroke-width="1.5"></path></g>
</g><circle cx="38" cy="38" r="15" fill="#3B2716"></circle><rect x="31" y="37" width="14" height="10" rx="2.5" fill="none" stroke="#FFF4E2" stroke-width="2.2"></rect><path d="M34 37v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#FFF4E2" stroke-width="2.2"></path>
''';

const ruleWallLockedSvg = r'''
<rect width="76" height="76" rx="16" fill="#E6D6BC"></rect><g opacity="0.45">
<g transform="translate(-26 0)"><rect x="56" y="6" width="16" height="64" rx="3" fill="#B07A4F"></rect><path d="M56 27 H72 M56 48 H72" stroke="#946140" stroke-width="1.4"></path></g>
</g><circle cx="38" cy="38" r="15" fill="#3B2716"></circle><rect x="31" y="37" width="14" height="10" rx="2.5" fill="none" stroke="#FFF4E2" stroke-width="2.2"></rect><path d="M34 37v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#FFF4E2" stroke-width="2.2"></path>
''';

/// Tangan penunjuk tutorial (`11-tutorial-level-1.html`), viewBox 52×64,
/// sebelum diputar 180° (`koTap`).
const tutorialHandSvg = r'''
    <path d="M14 8 a6 6 0 0 1 12 0 v18 h3 a5 5 0 0 1 5 5 v1 a5 5 0 0 1 6 4.5 v1 a5 5 0 0 1 5 5 v6 c0 10 -7 15 -16 15 h-5 c-8 0 -12 -4 -15 -10 l-6 -12 a4.5 4.5 0 0 1 7.5 -4.8 l3.5 5.3 z" fill="#FFE1C4" stroke="#3B2716" stroke-width="2.4" stroke-linejoin="round"></path>
    <path d="M26 26 v8 M34 32 v6 M40 37 v5" stroke="#3B2716" stroke-width="2" stroke-linecap="round" opacity="0.5"></path>
''';
