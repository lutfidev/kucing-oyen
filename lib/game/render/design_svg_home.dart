// Isi <svg> komponen desain rumah Oyen (langkah 21-26), disalin apa adanya
// dari docs/design/rumah-oyen/project/ (termasuk blok sc-if, sc-for, dan
// {{nama}}). Jangan disunting dengan tangan: salin ulang dari desain kalau
// desainnya berubah.
// test/game/render/design_sync_test.dart memastikan isinya masih sama.

/// Sprite kucing kamar, viewBox 100x100 (`Kucing.dc.html`).
const kittySvg = r'''
  <g transform="{{flipT}}">

    <sc-if value="{{isSit}}" hint-placeholder-val="{{ true }}">
      <ellipse cx="50" cy="92" rx="31" ry="6.5" fill="#7A4A1F" opacity="0.16"></ellipse>
    </sc-if>
    <sc-if value="{{isScratch}}" hint-placeholder-val="{{ false }}">
      <ellipse cx="56" cy="95" rx="42" ry="5" fill="#7A4A1F" opacity="0.16"></ellipse>
    </sc-if>
    <sc-if value="{{isLie}}" hint-placeholder-val="{{ false }}">
      <ellipse cx="54" cy="97" rx="46" ry="5" fill="#7A4A1F" opacity="0.16"></ellipse>
    </sc-if>

    <sc-if value="{{showPost}}" hint-placeholder-val="{{ false }}">
      <rect x="68" y="90" width="32" height="8" rx="3" fill="#B07A4F"></rect>
      <rect x="76" y="6" width="16" height="86" rx="3" fill="#D8A86F"></rect>
      <path d="M76 14 H92 M76 22 H92 M76 30 H92 M76 38 H92 M76 46 H92 M76 54 H92 M76 62 H92 M76 70 H92 M76 78 H92 M76 86 H92" stroke="#B78553" stroke-width="2" opacity="0.8"></path>
      <rect x="72" y="1" width="24" height="7" rx="3" fill="#B07A4F"></rect>
    </sc-if>

    <sc-if value="{{showTail}}" hint-placeholder-val="{{ true }}">
      <g class="kc-anim" style="{{tailStyle}}">
        <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
          <path d="{{tailD}}" stroke="{{c.edge}}" stroke-width="14" fill="none" stroke-linecap="round"></path>
        </sc-if>
        <path d="{{tailD}}" stroke="{{c.tail}}" stroke-width="11" fill="none" stroke-linecap="round"></path>
        <path d="{{tailTipD}}" stroke="{{c.tailTip}}" stroke-width="11" fill="none" stroke-linecap="round"></path>
      </g>
    </sc-if>

    <sc-if value="{{isSit}}" hint-placeholder-val="{{ true }}">
      <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
        <ellipse cx="50" cy="71" rx="28.6" ry="21.6" fill="{{c.edge}}"></ellipse>
      </sc-if>
      <ellipse cx="50" cy="71" rx="27" ry="20" fill="{{c.fur}}"></ellipse>
      <sc-for list="{{c.pBody}}" as="q" hint-placeholder-count="0">
        <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
      </sc-for>
      <ellipse cx="50" cy="77" rx="14" ry="10" fill="{{c.belly}}"></ellipse>
      <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
        <path d="M25 68 L31 70 M24 75 L30 76 M75 68 L69 70 M76 75 L70 76" stroke="{{c.stripe}}" stroke-width="2.6" stroke-linecap="round"></path>
      </sc-if>
      <sc-if value="{{pawLOn}}" hint-placeholder-val="{{ true }}">
        <ellipse cx="39" cy="{{pawL}}" rx="7" ry="5" fill="{{c.paw}}"></ellipse>
      </sc-if>
      <sc-if value="{{pawROn}}" hint-placeholder-val="{{ true }}">
        <ellipse cx="61" cy="{{pawR}}" rx="7" ry="5" fill="{{c.paw}}"></ellipse>
      </sc-if>
    </sc-if>

    <sc-if value="{{isScratch}}" hint-placeholder-val="{{ false }}">
      <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
        <ellipse cx="46" cy="68" rx="22.6" ry="25.6" fill="{{c.edge}}"></ellipse>
      </sc-if>
      <ellipse cx="46" cy="68" rx="21" ry="24" fill="{{c.fur}}"></ellipse>
      <sc-for list="{{c.pScratch}}" as="q" hint-placeholder-count="0">
        <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
      </sc-for>
      <ellipse cx="44" cy="74" rx="11" ry="13" fill="{{c.belly}}"></ellipse>
      <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
        <path d="M26 62 L32 64 M25 70 L31 71 M27 78 L33 78" stroke="{{c.stripe}}" stroke-width="2.6" stroke-linecap="round"></path>
      </sc-if>
      <ellipse cx="36" cy="92" rx="7" ry="4.5" fill="{{c.paw}}"></ellipse>
      <ellipse cx="56" cy="92" rx="7" ry="4.5" fill="{{c.paw}}"></ellipse>
    </sc-if>

    <sc-if value="{{isLie}}" hint-placeholder-val="{{ false }}">
      <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
        <ellipse cx="62" cy="84" rx="35.6" ry="13.6" fill="{{c.edge}}"></ellipse>
      </sc-if>
      <ellipse cx="62" cy="84" rx="34" ry="12" fill="{{c.fur}}"></ellipse>
      <sc-for list="{{c.pLesu}}" as="q" hint-placeholder-count="0">
        <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
      </sc-for>
      <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
        <path d="M64 74 Q66 84 64 94 M76 74 Q78 84 76 94 M87 77 Q89 84 87 91" stroke="{{c.stripe}}" stroke-width="3" fill="none" stroke-linecap="round"></path>
      </sc-if>
    </sc-if>

    <sc-if value="{{showHead}}" hint-placeholder-val="{{ true }}">
      <g class="kc-anim" style="{{headAnim}}">
      <g transform="{{headT}}">
        <g transform="{{earLT}}">
          <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
            <path d="M21 38 L23 11 L45 25 Z" fill="{{c.edge}}" stroke="{{c.edge}}" stroke-width="7" stroke-linejoin="round"></path>
          </sc-if>
          <path d="M21 38 L23 11 L45 25 Z" fill="{{c.earL}}" stroke="{{c.earL}}" stroke-width="4" stroke-linejoin="round"></path>
          <path d="M26 32 L27.5 18 L39 26 Z" fill="{{c.earIn}}" stroke="{{c.earIn}}" stroke-width="2" stroke-linejoin="round"></path>
          <sc-if value="{{c.earTipOn}}" hint-placeholder-val="{{ false }}">
            <path d="M21.8 19.5 L23 11 L30.5 15.8 Z" fill="{{c.earTip}}" stroke="{{c.earTip}}" stroke-width="4" stroke-linejoin="round"></path>
          </sc-if>
        </g>
        <g transform="{{earRT}}">
          <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
            <path d="M79 38 L77 11 L55 25 Z" fill="{{c.edge}}" stroke="{{c.edge}}" stroke-width="7" stroke-linejoin="round"></path>
          </sc-if>
          <path d="M79 38 L77 11 L55 25 Z" fill="{{c.earR}}" stroke="{{c.earR}}" stroke-width="4" stroke-linejoin="round"></path>
          <path d="M74 32 L72.5 18 L61 26 Z" fill="{{c.earIn}}" stroke="{{c.earIn}}" stroke-width="2" stroke-linejoin="round"></path>
          <sc-if value="{{c.earTipOn}}" hint-placeholder-val="{{ false }}">
            <path d="M78.2 19.5 L77 11 L69.5 15.8 Z" fill="{{c.earTip}}" stroke="{{c.earTip}}" stroke-width="4" stroke-linejoin="round"></path>
          </sc-if>
        </g>
        <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
          <ellipse cx="50" cy="42" rx="32.6" ry="26.6" fill="{{c.edge}}"></ellipse>
          <ellipse cx="50" cy="51" rx="35.1" ry="17.6" fill="{{c.edge}}"></ellipse>
        </sc-if>
        <ellipse cx="50" cy="42" rx="31" ry="25" fill="{{c.head}}"></ellipse>
        <ellipse cx="50" cy="51" rx="33.5" ry="16" fill="{{c.head}}"></ellipse>
        <sc-for list="{{c.pHead}}" as="q" hint-placeholder-count="0">
          <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
        </sc-for>
        <sc-if value="{{c.maskOn}}" hint-placeholder-val="{{ false }}">
          <ellipse cx="50" cy="52.5" rx="17" ry="12.5" fill="{{c.mask}}" opacity="0.92"></ellipse>
        </sc-if>
        <sc-if value="{{c.blazeOn}}" hint-placeholder-val="{{ false }}">
          <path d="M45 31 Q50 27 55 31 L58 50 Q50 47 42 50 Z" fill="#FFFFFF"></path>
        </sc-if>
        <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
          <path d="M43 19 L45 28 M50 17.5 L50 28 M57 19 L55 28" stroke="{{c.stripe}}" stroke-width="3.2" stroke-linecap="round"></path>
          <path d="M19 38 L27 40 M18 45 L26 45 M81 38 L73 40 M82 45 L74 45" stroke="{{c.stripe}}" stroke-width="2.8" stroke-linecap="round"></path>
        </sc-if>

        <g transform="{{faceT}}">
          <ellipse cx="50" cy="56" rx="11" ry="7.5" fill="{{c.muzzle}}"></ellipse>
          <ellipse cx="26" cy="55" rx="6" ry="3.5" fill="{{c.blush}}" opacity="{{blushOp}}"></ellipse>
          <ellipse cx="74" cy="55" rx="6" ry="3.5" fill="{{c.blush}}" opacity="{{blushOp}}"></ellipse>

          <g class="kc-anim" style="{{blinkStyle}}">
            <sc-if value="{{eyeSleepy}}" hint-placeholder-val="{{ true }}">
              <path d="M28.5 42 A8.5 8.5 0 0 0 45.5 42 Z" fill="{{c.eye}}"></path>
              <path d="M54.5 42 A8.5 8.5 0 0 0 71.5 42 Z" fill="{{c.eye}}"></path>
              <sc-if value="{{c.pupil}}" hint-placeholder-val="{{ false }}">
                <ellipse cx="37" cy="46.2" rx="1.8" ry="3.3" fill="#1A1515"></ellipse>
                <ellipse cx="63" cy="46.2" rx="1.8" ry="3.3" fill="#1A1515"></ellipse>
              </sc-if>
              <circle cx="40.5" cy="45" r="2.1" fill="#FFFFFF"></circle>
              <circle cx="66.5" cy="45" r="2.1" fill="#FFFFFF"></circle>
              <circle cx="34" cy="47.2" r="1" fill="#FFFFFF"></circle>
              <circle cx="60" cy="47.2" r="1" fill="#FFFFFF"></circle>
              <path d="M27.5 41.5 L46.5 41.5 M53.5 41.5 L72.5 41.5" stroke="{{c.line}}" stroke-width="2.6" stroke-linecap="round"></path>
            </sc-if>
            <sc-if value="{{eyeWide}}" hint-placeholder-val="{{ false }}">
              <circle cx="37" cy="42" r="9" fill="#FFFDF7" stroke="{{c.line}}" stroke-width="2"></circle>
              <circle cx="63" cy="42" r="9" fill="#FFFDF7" stroke="{{c.line}}" stroke-width="2"></circle>
              <circle cx="38" cy="43" r="4.6" fill="{{c.iris}}"></circle>
              <circle cx="64" cy="43" r="4.6" fill="{{c.iris}}"></circle>
              <circle cx="38" cy="43" r="2.3" fill="#1A1515"></circle>
              <circle cx="64" cy="43" r="2.3" fill="#1A1515"></circle>
              <circle cx="39.6" cy="41.2" r="1.3" fill="#FFFFFF"></circle>
              <circle cx="65.6" cy="41.2" r="1.3" fill="#FFFFFF"></circle>
            </sc-if>
          </g>
          <sc-if value="{{eyeClosed}}" hint-placeholder-val="{{ false }}">
            <path d="M29 43 Q37 49 45 43 M55 43 Q63 49 71 43" stroke="{{c.line}}" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <sc-if value="{{eyeHappy}}" hint-placeholder-val="{{ false }}">
            <path d="M29 46 Q37 37 45 46 M55 46 Q63 37 71 46" stroke="{{c.line}}" stroke-width="2.8" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <sc-if value="{{eyeSad}}" hint-placeholder-val="{{ false }}">
            <path d="M29.5 44 A7.5 7.5 0 0 0 44.5 44 Z" fill="{{c.eye}}"></path>
            <path d="M55.5 44 A7.5 7.5 0 0 0 70.5 44 Z" fill="{{c.eye}}"></path>
            <sc-if value="{{c.pupil}}" hint-placeholder-val="{{ false }}">
              <ellipse cx="37" cy="47.6" rx="1.5" ry="2.6" fill="#1A1515"></ellipse>
              <ellipse cx="63" cy="47.6" rx="1.5" ry="2.6" fill="#1A1515"></ellipse>
            </sc-if>
            <circle cx="40" cy="46.4" r="1.5" fill="#FFFFFF"></circle>
            <circle cx="66" cy="46.4" r="1.5" fill="#FFFFFF"></circle>
            <path d="M28 44.6 L46 42 M54 42 L72 44.6" stroke="{{c.line}}" stroke-width="2.6" stroke-linecap="round"></path>
          </sc-if>

          <path d="M47 51.5 L53 51.5 L50 55 Z" fill="{{c.nose}}" stroke="{{c.nose}}" stroke-width="1.5" stroke-linejoin="round"></path>
          <sc-if value="{{mouthW}}" hint-placeholder-val="{{ true }}">
            <path d="M45 58 Q47.5 61 50 58 Q52.5 61 55 58" stroke="{{c.mouth}}" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <sc-if value="{{mouthOpen}}" hint-placeholder-val="{{ false }}">
            <path d="M44.5 57.5 Q50 66 55.5 57.5 Z" fill="#8E3B2E" stroke="{{c.mouth}}" stroke-width="1.4" stroke-linejoin="round"></path>
          </sc-if>
          <sc-if value="{{mouthTongue}}" hint-placeholder-val="{{ false }}">
            <path d="M47.6 59.2 Q50 66.5 52.4 59.2 Z" fill="#E9707C" stroke="#C4525E" stroke-width="1" stroke-linejoin="round"></path>
            <path d="M45 58 Q47.5 61 50 58 Q52.5 61 55 58" stroke="{{c.mouth}}" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <sc-if value="{{mouthFrown}}" hint-placeholder-val="{{ false }}">
            <path d="M45.5 60.5 Q50 56.5 54.5 60.5" stroke="{{c.mouth}}" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <path d="M37 56 L24 54 M37 59 L25 61 M63 56 L76 54 M63 59 L75 61" stroke="{{c.whisker}}" stroke-width="1.1" opacity="{{c.whiskerOp}}" stroke-linecap="round"></path>

          <sc-if value="{{a.kacamata}}" hint-placeholder-val="{{ false }}">
            <circle cx="37" cy="43" r="10.5" fill="none" stroke="{{glassInk}}" stroke-width="2.2"></circle>
            <circle cx="63" cy="43" r="10.5" fill="none" stroke="{{glassInk}}" stroke-width="2.2"></circle>
            <path d="M47.5 42 Q50 39.5 52.5 42 M26.5 41 L19 38.5 M73.5 41 L81 38.5" stroke="{{glassInk}}" stroke-width="2" fill="none" stroke-linecap="round"></path>
            <path d="M31 37.5 Q33 35.6 35.4 35.2 M57 37.5 Q59 35.6 61.4 35.2" stroke="#FFFFFF" stroke-width="1.4" fill="none" stroke-linecap="round" opacity="0.8"></path>
          </sc-if>
        </g>

        <sc-if value="{{neckOn}}" hint-placeholder-val="{{ false }}">
          <sc-if value="{{a.bandana}}" hint-placeholder-val="{{ false }}">
            <sc-if value="{{dangleOn}}" hint-placeholder-val="{{ true }}">
              <path d="M33 66 Q50 71.5 67 66 L50 82 Z" fill="#2F86B8" stroke="#24709B" stroke-width="1" stroke-linejoin="round"></path>
              <circle cx="44" cy="71" r="1.3" fill="#FFFFFF"></circle>
              <circle cx="55.5" cy="71" r="1.3" fill="#FFFFFF"></circle>
              <circle cx="50" cy="76" r="1.3" fill="#FFFFFF"></circle>
            </sc-if>
            <path d="M28 63.5 Q50 72.5 72 63.5" stroke="#2F86B8" stroke-width="4.6" fill="none" stroke-linecap="round"></path>
          </sc-if>
          <sc-if value="{{a.kalung}}" hint-placeholder-val="{{ false }}">
            <path d="M28 63.5 Q50 72.5 72 63.5" stroke="#E0453A" stroke-width="4.2" fill="none" stroke-linecap="round"></path>
            <sc-if value="{{dangleOn}}" hint-placeholder-val="{{ true }}">
              <circle cx="50" cy="72.8" r="4.3" fill="#FFC83D" stroke="#C98F00" stroke-width="1.2"></circle>
              <path d="M47.4 73.6 H52.6" stroke="#9E6C00" stroke-width="1" stroke-linecap="round"></path>
              <circle cx="48.6" cy="71.3" r="0.9" fill="#FFFFFF"></circle>
            </sc-if>
          </sc-if>
        </sc-if>

        <sc-if value="{{a.topiPesta}}" hint-placeholder-val="{{ false }}">
          <path d="M41 21 L52 -13 L62 22 Q51 25 41 21 Z" fill="#7FC8E8" stroke="#4FA3C9" stroke-width="1.2" stroke-linejoin="round"></path>
          <path d="M42.6 16 Q51.5 18.6 60.6 17.2" stroke="#FFFBF3" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
          <circle cx="50" cy="6" r="1.7" fill="#F07F9A"></circle>
          <circle cx="54.6" cy="0" r="1.4" fill="#FFC83D"></circle>
          <circle cx="56" cy="10" r="1.5" fill="#F07F9A"></circle>
          <circle cx="52" cy="-14" r="4.2" fill="#FFC83D"></circle>
        </sc-if>
        <sc-if value="{{a.beanie}}" hint-placeholder-val="{{ false }}">
          <path d="M30 26 Q30 9 50 8 Q70 9 70 26 Q50 21 30 26 Z" fill="#2BB5A0"></path>
          <path d="M29 27.5 Q50 21.5 71 27.5 L70.5 22.5 Q50 16.5 29.5 22.5 Z" fill="#1C8676"></path>
          <path d="M35 21.4 L35 26 M42 19.4 L42 24 M50 18.8 L50 23.2 M58 19.4 L58 24 M65 21.4 L65 26" stroke="#14695C" stroke-width="1.2" stroke-linecap="round"></path>
          <circle cx="50" cy="6.5" r="5.5" fill="#FFFBF3" stroke="#E2C79C" stroke-width="1"></circle>
        </sc-if>
        <sc-if value="{{a.pita}}" hint-placeholder-val="{{ false }}">
          <path d="M63 24 L60 31.5 M65 24 L68.5 31" stroke="#F07F9A" stroke-width="2.2" stroke-linecap="round"></path>
          <path d="M64 21 L55.5 14.5 L56.5 27 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1.2" stroke-linejoin="round"></path>
          <path d="M64 21 L72.5 14 L72 27.5 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1.2" stroke-linejoin="round"></path>
          <circle cx="64" cy="21" r="3.2" fill="#D9607A"></circle>
        </sc-if>
        <sc-if value="{{a.mahkota}}" hint-placeholder-val="{{ false }}">
          <ellipse cx="31" cy="21" rx="3.8" ry="1.8" fill="#5FAE5A" transform="rotate(-35 31 21)"></ellipse>
          <ellipse cx="43" cy="15.5" rx="3.8" ry="1.8" fill="#4E9A4A" transform="rotate(-15 43 15.5)"></ellipse>
          <ellipse cx="57" cy="15.5" rx="3.8" ry="1.8" fill="#4E9A4A" transform="rotate(15 57 15.5)"></ellipse>
          <ellipse cx="69" cy="21" rx="3.8" ry="1.8" fill="#5FAE5A" transform="rotate(35 69 21)"></ellipse>
          <circle cx="25" cy="25.5" r="4.2" fill="#F07F9A"></circle>
          <circle cx="36.5" cy="18.4" r="4.2" fill="#FFFBF3" stroke="#E2C79C" stroke-width="0.8"></circle>
          <circle cx="50" cy="15.6" r="4.4" fill="#B79CE0"></circle>
          <circle cx="63.5" cy="18.4" r="4.2" fill="#FFC83D"></circle>
          <circle cx="75" cy="25.5" r="4.2" fill="#F07F9A"></circle>
          <circle cx="25" cy="25.5" r="1.5" fill="#FFE6A8"></circle>
          <circle cx="36.5" cy="18.4" r="1.5" fill="#F59A33"></circle>
          <circle cx="50" cy="15.6" r="1.6" fill="#FFE6A8"></circle>
          <circle cx="63.5" cy="18.4" r="1.5" fill="#F59A33"></circle>
          <circle cx="75" cy="25.5" r="1.5" fill="#FFE6A8"></circle>
        </sc-if>
      </g>
      </g>
    </sc-if>

    <sc-if value="{{isSleep}}" hint-placeholder-val="{{ false }}">
      <ellipse cx="52" cy="86" rx="42" ry="8" fill="#7A4A1F" opacity="0.16"></ellipse>
      <g class="kc-anim" style="{{sleepAnim}}">
        <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
          <ellipse cx="56" cy="60" rx="39.6" ry="28.6" fill="{{c.edge}}"></ellipse>
          <path d="M14 52 L13 33 L29 43 Z M43 44 L52 31 L56 48 Z" fill="{{c.edge}}" stroke="{{c.edge}}" stroke-width="6.5" stroke-linejoin="round"></path>
          <ellipse cx="34" cy="61" rx="25.6" ry="19.6" fill="{{c.edge}}"></ellipse>
          <ellipse cx="34" cy="66" rx="27.6" ry="14.6" fill="{{c.edge}}"></ellipse>
        </sc-if>
        <ellipse cx="56" cy="60" rx="38" ry="27" fill="{{c.fur}}"></ellipse>
        <sc-for list="{{c.pSleepBody}}" as="q" hint-placeholder-count="0">
          <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
        </sc-for>
        <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
          <path d="M44 36 Q48 45 44 54 M58 33.5 Q62 44 58 54 M72 36 Q75 45 71 55 M84 44 Q86 51 82 58" stroke="{{c.stripe}}" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
        </sc-if>
        <path d="M14 52 L13 33 L29 43 Z" fill="{{c.earL}}" stroke="{{c.earL}}" stroke-width="3.5" stroke-linejoin="round"></path>
        <path d="M43 44 L52 31 L56 48 Z" fill="{{c.earR}}" stroke="{{c.earR}}" stroke-width="3.5" stroke-linejoin="round"></path>
        <path d="M17 47 L16.5 38 L24 43 Z" fill="{{c.earIn}}"></path>
        <sc-if value="{{c.earTipOn}}" hint-placeholder-val="{{ false }}">
          <path d="M13.2 39 L13 33 L18.4 36.4 Z" fill="{{c.earTip}}" stroke="{{c.earTip}}" stroke-width="3.5" stroke-linejoin="round"></path>
        </sc-if>
        <ellipse cx="34" cy="61" rx="24" ry="18" fill="{{c.head}}"></ellipse>
        <ellipse cx="34" cy="66" rx="26" ry="13" fill="{{c.head}}"></ellipse>
        <sc-for list="{{c.pSleepHead}}" as="q" hint-placeholder-count="0">
          <ellipse cx="{{q.cx}}" cy="{{q.cy}}" rx="{{q.rx}}" ry="{{q.ry}}" fill="{{q.f}}"></ellipse>
        </sc-for>
        <sc-if value="{{c.maskOn}}" hint-placeholder-val="{{ false }}">
          <ellipse cx="34" cy="68" rx="12" ry="8.5" fill="{{c.mask}}" opacity="0.92"></ellipse>
        </sc-if>
        <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
          <path d="M28 46 L30 52 M34 45 L34 52 M40 46 L38 52" stroke="{{c.stripe}}" stroke-width="2.8" stroke-linecap="round"></path>
        </sc-if>
        <ellipse cx="34" cy="70" rx="7.5" ry="4.8" fill="{{c.muzzle}}"></ellipse>
        <ellipse cx="16" cy="67" rx="5" ry="3" fill="{{c.blush}}" opacity="{{blushOp}}"></ellipse>
        <ellipse cx="52" cy="67" rx="5" ry="3" fill="{{c.blush}}" opacity="{{blushOp}}"></ellipse>
        <path d="M19 62 Q25 67 31 62 M37 62 Q43 67 49 62" stroke="{{c.line}}" stroke-width="2.4" fill="none" stroke-linecap="round"></path>
        <path d="M32 67.5 L36 67.5 L34 70 Z" fill="{{c.nose}}" stroke="{{c.nose}}" stroke-width="1.2" stroke-linejoin="round"></path>

        <sc-if value="{{a.kacamata}}" hint-placeholder-val="{{ false }}">
          <circle cx="25" cy="62.5" r="6.4" fill="none" stroke="{{glassInk}}" stroke-width="1.7"></circle>
          <circle cx="43" cy="62.5" r="6.4" fill="none" stroke="{{glassInk}}" stroke-width="1.7"></circle>
          <path d="M31.4 62 Q34 60.2 36.6 62" stroke="{{glassInk}}" stroke-width="1.5" fill="none"></path>
        </sc-if>
        <sc-if value="{{a.kalung}}" hint-placeholder-val="{{ false }}">
          <path d="M22 77.5 Q34 83 46 77.5" stroke="#E0453A" stroke-width="3.6" fill="none" stroke-linecap="round"></path>
          <circle cx="38" cy="82" r="3" fill="#FFC83D" stroke="#C98F00" stroke-width="1"></circle>
        </sc-if>
        <sc-if value="{{a.bandana}}" hint-placeholder-val="{{ false }}">
          <path d="M25 79 Q34 83 43 79 L34 88 Z" fill="#2F86B8"></path>
          <path d="M22 77.5 Q34 83 46 77.5" stroke="#2F86B8" stroke-width="3.6" fill="none" stroke-linecap="round"></path>
        </sc-if>
        <sc-if value="{{a.topiPesta}}" hint-placeholder-val="{{ false }}">
          <path d="M20 46 L24 28 L34 44 Q27 47 20 46 Z" fill="#7FC8E8" stroke="#4FA3C9" stroke-width="1" stroke-linejoin="round"></path>
          <path d="M21.4 41 Q26 42.4 31 41.4" stroke="#FFFBF3" stroke-width="2" fill="none" stroke-linecap="round"></path>
          <circle cx="24" cy="27" r="3.4" fill="#FFC83D"></circle>
        </sc-if>
        <sc-if value="{{a.beanie}}" hint-placeholder-val="{{ false }}">
          <path d="M13 54 Q14 41 33 41 Q51 41 53 53 Q33 48 13 54 Z" fill="#2BB5A0"></path>
          <path d="M12.5 55 Q33 49 54 55 L53.5 51 Q33 45 13 51 Z" fill="#1C8676"></path>
          <circle cx="33" cy="40" r="4" fill="#FFFBF3" stroke="#E2C79C" stroke-width="0.8"></circle>
        </sc-if>
        <sc-if value="{{a.pita}}" hint-placeholder-val="{{ false }}">
          <path d="M44 46 L37.5 41 L38 51 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1" stroke-linejoin="round"></path>
          <path d="M44 46 L50.5 41 L50 51 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1" stroke-linejoin="round"></path>
          <circle cx="44" cy="46" r="2.6" fill="#D9607A"></circle>
        </sc-if>
        <sc-if value="{{a.mahkota}}" hint-placeholder-val="{{ false }}">
          <circle cx="15" cy="52" r="3.2" fill="#F07F9A"></circle>
          <circle cx="23" cy="46" r="3.2" fill="#FFFBF3" stroke="#E2C79C" stroke-width="0.7"></circle>
          <circle cx="33" cy="43.5" r="3.4" fill="#B79CE0"></circle>
          <circle cx="43" cy="46" r="3.2" fill="#FFC83D"></circle>
          <circle cx="51" cy="52" r="3.2" fill="#F07F9A"></circle>
          <circle cx="33" cy="43.5" r="1.2" fill="#FFE6A8"></circle>
        </sc-if>

        <sc-if value="{{hasEdge}}" hint-placeholder-val="{{ false }}">
          <path d="M92 62 C98 86 62 96 26 88" stroke="{{c.edge}}" stroke-width="14" fill="none" stroke-linecap="round"></path>
        </sc-if>
        <path d="M92 62 C98 86 62 96 26 88" stroke="{{c.tail}}" stroke-width="11" fill="none" stroke-linecap="round"></path>
        <path d="M30 89 C28 88.5 27 88.3 26 88" stroke="{{c.tailTip}}" stroke-width="11" fill="none" stroke-linecap="round"></path>
        <sc-if value="{{c.stripes}}" hint-placeholder-val="{{ true }}">
          <path d="M76 88 L74 82 M88 80 L84 76" stroke="{{c.stripe}}" stroke-width="2.6" stroke-linecap="round"></path>
        </sc-if>
      </g>
    </sc-if>

    <sc-if value="{{acc2On}}" hint-placeholder-val="{{ false }}">
      <g class="kc-anim" style="{{accAnim}}">
      <g transform="{{accT}}">
        <sc-if value="{{b.syal}}" hint-placeholder-val="{{ false }}">
          <sc-if value="{{dangle2}}" hint-placeholder-val="{{ true }}">
            <g class="kc-anim" style="{{syalAnim}}">
              <path d="M58 71 L58.5 89 L65 89 L64.5 70 Z" fill="#4E9A4A"></path>
              <path d="M63 69 L66 87 L72.5 86 L69 68 Z" fill="#5FAE5A"></path>
              <path d="M59 89 v3 M61.5 89 v3 M64 89 v3 M66.5 87 v3 M69 86.6 v3 M71.5 86.2 v3" stroke="#3F8A44" stroke-width="1.4" stroke-linecap="round"></path>
            </g>
          </sc-if>
          <path d="M27 62 Q50 74 73 62 L74 68.5 Q50 81 26 68.5 Z" fill="#5FAE5A" stroke="#4E9A4A" stroke-width="1" stroke-linejoin="round"></path>
          <path d="M35 66.5 Q36 70 35.5 73 M43 68.6 V75.6 M50 69.4 V76.4 M57 68.6 V75.6 M65 66.5 Q64 70 64.5 73" stroke="#FFFBF3" stroke-width="1.8" stroke-linecap="round" opacity="0.85"></path>
        </sc-if>
        <sc-if value="{{b.dasiKupu}}" hint-placeholder-val="{{ false }}">
          <path d="M30 64.5 Q50 71.5 70 64.5" stroke="#B8352B" stroke-width="2" fill="none" stroke-linecap="round"></path>
          <path d="M50 68.5 L39.5 62.5 L39.5 74.5 Z" fill="#E0453A" stroke="#B8352B" stroke-width="1.2" stroke-linejoin="round"></path>
          <path d="M50 68.5 L60.5 62.5 L60.5 74.5 Z" fill="#E0453A" stroke="#B8352B" stroke-width="1.2" stroke-linejoin="round"></path>
          <path d="M42.5 66 L46 68.5 L42.5 71 M57.5 66 L54 68.5 L57.5 71" stroke="#B8352B" stroke-width="0.9" fill="none" stroke-linecap="round"></path>
          <rect x="47.4" y="65.8" width="5.2" height="5.4" rx="1.6" fill="#B8352B"></rect>
        </sc-if>
        <sc-if value="{{b.baret}}" hint-placeholder-val="{{ false }}">
          <path d="M28 23 Q26 12 45 9 Q67 6 76 15 Q78 22 66 23.5 Q46 26.5 28 23 Z" fill="#C2492F"></path>
          <path d="M30 23.6 Q48 27 67 23.4" stroke="#9A3520" stroke-width="2.4" fill="none" stroke-linecap="round"></path>
          <path d="M48 9 L49.5 3.5" stroke="#9A3520" stroke-width="2.6" stroke-linecap="round"></path>
          <path d="M40 12.5 Q52 10 64 12" stroke="#D9604A" stroke-width="1.4" fill="none" stroke-linecap="round" opacity="0.8"></path>
        </sc-if>
        <sc-if value="{{b.jepitBunga}}" hint-placeholder-val="{{ false }}">
          <path d="M28 28 L41 24" stroke="#7FC8E8" stroke-width="2.4" stroke-linecap="round"></path>
          <ellipse cx="41" cy="26.5" rx="3.4" ry="1.7" fill="#5FAE5A" transform="rotate(25 41 26.5)"></ellipse>
          <circle cx="34" cy="16.6" r="3.4" fill="#F7A8C0"></circle>
          <circle cx="38.4" cy="19.8" r="3.4" fill="#F7A8C0"></circle>
          <circle cx="36.7" cy="24.8" r="3.4" fill="#F7A8C0"></circle>
          <circle cx="31.3" cy="24.8" r="3.4" fill="#F7A8C0"></circle>
          <circle cx="29.6" cy="19.8" r="3.4" fill="#F7A8C0"></circle>
          <circle cx="34" cy="21.2" r="2.6" fill="#FFC83D"></circle>
        </sc-if>
        <sc-if value="{{b.topiPenyihir}}" hint-placeholder-val="{{ false }}">
          <path d="M37 22 Q42 6 49 -6 Q57 -19 72 -14 Q61 -11 58 -1 Q59 10 63 21 Q50 18.5 37 22 Z" fill="#5E4A8A" stroke="#4B3B6E" stroke-width="1.2" stroke-linejoin="round"></path>
          <path d="M38.4 18 Q50 15.4 62 17.6" stroke="#FFC83D" stroke-width="3" fill="none" stroke-linecap="round"></path>
          <path d="M22 24.5 Q50 16 78 24.5 Q50 31 22 24.5 Z" fill="#4B3B6E"></path>
          <path d="M51 4 L52.2 7.2 L55.6 7.4 L53 9.6 L53.8 13 L51 11.1 L48.2 13 L49 9.6 L46.4 7.4 L49.8 7.2 Z" fill="#FFC83D"></path>
        </sc-if>
        <sc-if value="{{b.headphone}}" hint-placeholder-val="{{ false }}">
          <path d="M40 22 Q40 7 50 7 Q60 7 60 22" stroke="#3B2716" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
          <rect x="35" y="17" width="9" height="11" rx="3.8" fill="#2F86B8" stroke="#24709B" stroke-width="1"></rect>
          <rect x="56" y="17" width="9" height="11" rx="3.8" fill="#2F86B8" stroke="#24709B" stroke-width="1"></rect>
          <path d="M37.5 20 V25 M62.5 20 V25" stroke="#7FC8E8" stroke-width="1.6" stroke-linecap="round"></path>
          <sc-if value="{{noteOn}}" hint-placeholder-val="{{ false }}">
            <g class="kc-anim" style="{{noteAnim}}">
              <path d="M80 4 V-6 L86 -8 V2" stroke="#2F86B8" stroke-width="1.6" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
              <ellipse cx="78.6" cy="4.4" rx="2.4" ry="1.8" fill="#2F86B8"></ellipse>
              <ellipse cx="84.6" cy="2.4" rx="2.4" ry="1.8" fill="#2F86B8"></ellipse>
            </g>
          </sc-if>
        </sc-if>
        <sc-if value="{{b.tandukRusa}}" hint-placeholder-val="{{ false }}">
          <path d="M41 20 Q38 10 33 3 M37 10.5 Q32 10 28.5 7 M34.6 5.5 Q34.8 0.5 37.5 -3" stroke="#B07A4F" stroke-width="3.6" fill="none" stroke-linecap="round"></path>
          <path d="M59 20 Q62 10 67 3 M63 10.5 Q68 10 71.5 7 M65.4 5.5 Q65.2 0.5 62.5 -3" stroke="#B07A4F" stroke-width="3.6" fill="none" stroke-linecap="round"></path>
          <path d="M41 20 Q38 10 33 3 M59 20 Q62 10 67 3" stroke="#D8A86F" stroke-width="1.2" fill="none" stroke-linecap="round" opacity="0.8"></path>
        </sc-if>
        <sc-if value="{{b.mahkotaRaja}}" hint-placeholder-val="{{ false }}">
          <path d="M33 23 L31 8 L40.5 15 L50 3 L59.5 15 L69 8 L67 23 Q50 20 33 23 Z" fill="#FFC83D" stroke="#C98F00" stroke-width="1.4" stroke-linejoin="round"></path>
          <path d="M33 23 Q50 20 67 23 L67 18.6 Q50 15.6 33 18.6 Z" fill="#F0B020"></path>
          <circle cx="50" cy="18.4" r="2.3" fill="#E0453A"></circle>
          <circle cx="41" cy="19.6" r="1.7" fill="#2F86B8"></circle>
          <circle cx="59" cy="19.6" r="1.7" fill="#2BB5A0"></circle>
          <circle cx="31" cy="8" r="2" fill="#FFE6A8" stroke="#C98F00" stroke-width="0.8"></circle>
          <circle cx="50" cy="3" r="2.2" fill="#FFE6A8" stroke="#C98F00" stroke-width="0.8"></circle>
          <circle cx="69" cy="8" r="2" fill="#FFE6A8" stroke="#C98F00" stroke-width="0.8"></circle>
          <path class="kc-anim" style="{{crownTw}}" d="M74 -2 L75.2 1.4 L78.6 2.6 L75.2 3.8 L74 7.2 L72.8 3.8 L69.4 2.6 L72.8 1.4 Z" fill="#FFF4C2"></path>
        </sc-if>
        <sc-if value="{{b.topiKoki}}" hint-placeholder-val="{{ false }}">
          <g transform="rotate(-8 50 22)">
            <path d="M34 26 L34 15.5 Q50 11.5 66 15.5 L66 26 Q50 22 34 26 Z" fill="#FFFFFF" stroke="#D9CBB5" stroke-width="1.4" stroke-linejoin="round"></path>
            <path d="M40 24.6 L40 14.2 M46 23.6 L46 12.9 M52 23.4 L52 12.7 M58 23.8 L58 13.2" stroke="#E9DFD0" stroke-width="1.3" stroke-linecap="round"></path>
            <path d="M33.5 16.5 Q22 10 28 -1 Q32 -11 42 -7.5 Q46 -17 56.5 -11.5 Q67 -15.5 70.5 -5 Q80 2.5 67 15.5 Q50 11 33.5 16.5 Z" fill="#FFFFFF" stroke="#D9CBB5" stroke-width="1.6" stroke-linejoin="round"></path>
            <path d="M41.5 -5.5 Q44 4 40.5 12.8 M56.5 -9.5 Q58.5 2 56 12" stroke="#ECE3D6" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
            <path d="M30 2 Q28 -4 33 -7" stroke="#FFFFFF" stroke-width="1.6" fill="none" stroke-linecap="round" opacity="0.9"></path>
          </g>
        </sc-if>
      </g>
      </g>
    </sc-if>

    <sc-if value="{{isLick}}" hint-placeholder-val="{{ false }}">
      <g class="kc-anim" style="{{lickAnim}}">
        <path d="M34 83 Q30 72 39 65" stroke="{{c.leg}}" stroke-width="10" fill="none" stroke-linecap="round"></path>
        <ellipse cx="41" cy="63" rx="6.5" ry="5.5" fill="{{c.paw}}"></ellipse>
      </g>
    </sc-if>

    <sc-if value="{{isPlay}}" hint-placeholder-val="{{ false }}">
      <g class="kc-anim" style="{{tapAnim}}">
        <path d="M64 80 Q76 71 84 76" stroke="{{c.leg}}" stroke-width="10" fill="none" stroke-linecap="round"></path>
        <ellipse cx="86" cy="78" rx="6.5" ry="5" fill="{{c.paw}}"></ellipse>
      </g>
      <sc-if value="{{toyBall}}" hint-placeholder-val="{{ true }}">
        <path d="M84 96 Q76 100 66 97" stroke="#E0565B" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
        <g class="kc-anim" style="{{ballAnim}}">
          <circle cx="92" cy="90" r="8" fill="#E0565B"></circle>
          <path d="M85 87 Q92 83 99 89 M84.5 92 Q92 89 99.5 94 M89 83 Q86 90 90 97.5 M95 82.6 Q98 90 95 97.6" stroke="#B23B44" stroke-width="1.4" fill="none" stroke-linecap="round"></path>
        </g>
      </sc-if>
      <sc-if value="{{toyMouse}}" hint-placeholder-val="{{ false }}">
        <g class="kc-anim" style="{{ballAnim}}">
          <path d="M101 92 Q107 87 104 82" stroke="#E07A8A" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
          <ellipse cx="94" cy="91" rx="9" ry="5.6" fill="#9C95AE"></ellipse>
          <circle cx="89" cy="85.6" r="3.4" fill="#C2BBD3"></circle>
          <circle cx="89" cy="85.6" r="1.7" fill="#F2A7B5"></circle>
          <circle cx="87.4" cy="89.6" r="0.9" fill="#3B2716"></circle>
          <circle cx="85.2" cy="91.6" r="1.1" fill="#E07A8A"></circle>
        </g>
      </sc-if>
    </sc-if>

    <sc-if value="{{isScratch}}" hint-placeholder-val="{{ false }}">
      <g class="kc-anim" style="{{scratchA}}">
        <path d="M54 58 L72 34" stroke="{{c.leg}}" stroke-width="9" fill="none" stroke-linecap="round"></path>
        <ellipse cx="75" cy="33" rx="5.5" ry="4.5" fill="{{c.paw}}"></ellipse>
      </g>
      <g class="kc-anim" style="{{scratchB}}">
        <path d="M56 66 L72 48" stroke="{{c.leg}}" stroke-width="9" fill="none" stroke-linecap="round"></path>
        <ellipse cx="75" cy="47" rx="5.5" ry="4.5" fill="{{c.paw}}"></ellipse>
      </g>
      <path d="M82 28 L84 37 M85.5 30 L87.5 39 M82 43 L84 51" stroke="#8E5A30" stroke-width="1.4" stroke-linecap="round"></path>
    </sc-if>

    <sc-if value="{{isLie}}" hint-placeholder-val="{{ false }}">
      <ellipse cx="30" cy="96" rx="7" ry="4.2" fill="{{c.paw}}"></ellipse>
      <ellipse cx="57" cy="96" rx="7" ry="4.2" fill="{{c.paw}}"></ellipse>
    </sc-if>

    <sc-if value="{{isEat}}" hint-placeholder-val="{{ false }}">
      <g transform="translate(23 72)">
        <path d="M4 8 L50 8 L45 25 Q27 29 9 25 Z" fill="#2F86B8"></path>
        <path d="M17 16 Q22 12.5 27 16 Q22 19.5 17 16 Z M27 16 L31 13.4 L31 18.6 Z" fill="#BFE7F7"></path>
        <ellipse cx="27" cy="8" rx="23" ry="4.6" fill="#5FB2DE"></ellipse>
        <ellipse cx="27" cy="7.4" rx="18" ry="3.8" fill="#B07A4F"></ellipse>
        <circle cx="19" cy="6" r="1.6" fill="#8E5A30"></circle>
        <circle cx="27" cy="5" r="1.7" fill="#D9A066"></circle>
        <circle cx="35" cy="6.4" r="1.5" fill="#8E5A30"></circle>
        <circle cx="31" cy="4.6" r="1.3" fill="#8E5A30"></circle>
      </g>
    </sc-if>
  </g>

  <sc-if value="{{isHappy}}" hint-placeholder-val="{{ false }}">
    <path class="kc-anim" style="{{tw1}}" d="M8 14 L9.8 19.2 L15 21 L9.8 22.8 L8 28 L6.2 22.8 L1 21 L6.2 19.2 Z" fill="#FFC83D"></path>
    <path class="kc-anim" style="{{tw2}}" d="M92 6 L93.4 10.6 L98 12 L93.4 13.4 L92 18 L90.6 13.4 L86 12 L90.6 10.6 Z" fill="#FFC83D"></path>
    <path class="kc-anim" style="{{tw3}}" d="M98 40 L99 43 L102 44 L99 45 L98 48 L97 45 L94 44 L97 43 Z" fill="#FFC83D"></path>
  </sc-if>
  <sc-if value="{{isPetted}}" hint-placeholder-val="{{ false }}">
    <text x="70" y="8" font-size="13" font-weight="700" fill="#A8456E" font-family="Fredoka, sans-serif">purr~</text>
    <g class="kc-anim" style="{{heartAnim}}">
      <path d="M90 28 C86 24.5 86 20.5 89 20.5 C90.4 20.5 91 21.5 91.5 22.4 C92 21.5 92.6 20.5 94 20.5 C97 20.5 97 24.5 93 28 L91.5 29.4 Z" fill="#F07F9A"></path>
    </g>
    <g class="kc-anim" style="{{heartAnim2}}">
      <path d="M6 30 C3.4 27.6 3.4 25 5.4 25 C6.3 25 6.7 25.6 7 26.2 C7.3 25.6 7.7 25 8.6 25 C10.6 25 10.6 27.6 8 30 L7 31 Z" fill="#F07F9A" opacity="0.8"></path>
    </g>
  </sc-if>
  <sc-if value="{{isSleep}}" hint-placeholder-val="{{ false }}">
    <g class="kc-anim" style="{{zzzAnim}}">
      <g transform="translate(-26 16)" fill="#2F86B8" font-family="Fredoka, sans-serif" font-weight="700">
        <text x="80" y="16" font-size="18">Z</text>
        <text x="94" y="3" font-size="13">z</text>
        <text x="104" y="-7" font-size="9">z</text>
      </g>
    </g>
  </sc-if>
''';

/// Ikon aksesoris, viewBox 48x48 (`IkonAksesoris.dc.html`).
const accessoryIconSvg = r'''
    <sc-if value="{{a.none}}" hint-placeholder-val="{{ false }}">
      <circle cx="24" cy="24" r="15" fill="none" stroke="#CDB48C" stroke-width="2.6" stroke-dasharray="4 4"></circle>
      <path d="M14 34 L34 14" stroke="#CDB48C" stroke-width="2.6" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{a.topiPesta}}" hint-placeholder-val="{{ true }}">
      <path d="M13 42 L24 6 L35 42 Q24 46 13 42 Z" fill="#7FC8E8" stroke="#4FA3C9" stroke-width="1.6" stroke-linejoin="round"></path>
      <path d="M15.6 34 Q24 37 32.6 34.4" stroke="#FFFBF3" stroke-width="3" fill="none" stroke-linecap="round"></path>
      <circle cx="21" cy="24" r="2" fill="#F07F9A"></circle>
      <circle cx="27" cy="18" r="1.8" fill="#FFC83D"></circle>
      <circle cx="27.5" cy="28" r="1.8" fill="#F07F9A"></circle>
      <circle cx="24" cy="6" r="4.6" fill="#FFC83D"></circle>
    </sc-if>
    <sc-if value="{{a.beanie}}" hint-placeholder-val="{{ false }}">
      <path d="M8 34 Q8 11 24 10 Q40 11 40 34 Q24 29 8 34 Z" fill="#2BB5A0"></path>
      <path d="M7 38 Q24 32 41 38 L40.5 31.5 Q24 25.5 7.5 31.5 Z" fill="#1C8676"></path>
      <path d="M13 30 L13 35.6 M20 28.4 L20 34 M28 28.4 L28 34 M35 30 L35 35.6" stroke="#14695C" stroke-width="1.4" stroke-linecap="round"></path>
      <circle cx="24" cy="9" r="6" fill="#FFFBF3" stroke="#E2C79C" stroke-width="1.2"></circle>
    </sc-if>
    <sc-if value="{{a.pita}}" hint-placeholder-val="{{ false }}">
      <path d="M22 27 L16 41 M26 27 L32 41" stroke="#F07F9A" stroke-width="3.6" stroke-linecap="round"></path>
      <path d="M24 23 L7 12 L9 34 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1.6" stroke-linejoin="round"></path>
      <path d="M24 23 L41 12 L39 34 Z" fill="#F07F9A" stroke="#D9607A" stroke-width="1.6" stroke-linejoin="round"></path>
      <circle cx="24" cy="23" r="5" fill="#D9607A"></circle>
    </sc-if>
    <sc-if value="{{a.kalung}}" hint-placeholder-val="{{ false }}">
      <path d="M7 14 Q24 32 41 14" stroke="#E0453A" stroke-width="5" fill="none" stroke-linecap="round"></path>
      <circle cx="24" cy="32" r="8" fill="#FFC83D" stroke="#C98F00" stroke-width="1.8"></circle>
      <path d="M19.5 33.5 H28.5" stroke="#9E6C00" stroke-width="1.6" stroke-linecap="round"></path>
      <circle cx="24" cy="37.4" r="1.4" fill="#9E6C00"></circle>
      <circle cx="21" cy="29" r="1.6" fill="#FFFFFF"></circle>
    </sc-if>
    <sc-if value="{{a.bandana}}" hint-placeholder-val="{{ false }}">
      <path d="M8 15 Q24 22 40 15 L24 42 Z" fill="#2F86B8" stroke="#24709B" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M5 12 Q24 21 43 12" stroke="#2F86B8" stroke-width="5" fill="none" stroke-linecap="round"></path>
      <circle cx="18" cy="23" r="1.8" fill="#FFFFFF"></circle>
      <circle cx="30" cy="23" r="1.8" fill="#FFFFFF"></circle>
      <circle cx="24" cy="31" r="1.8" fill="#FFFFFF"></circle>
    </sc-if>
    <sc-if value="{{a.kacamata}}" hint-placeholder-val="{{ false }}">
      <circle cx="14" cy="25" r="9" fill="#FFFFFF" fill-opacity="0.4" stroke="#3B2716" stroke-width="3"></circle>
      <circle cx="34" cy="25" r="9" fill="#FFFFFF" fill-opacity="0.4" stroke="#3B2716" stroke-width="3"></circle>
      <path d="M21.5 23.5 Q24 21 26.5 23.5 M5 23 L1 20 M43 23 L47 20" stroke="#3B2716" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
      <path d="M9 21 Q11 18.6 14 18.2 M29 21 Q31 18.6 34 18.2" stroke="#8FD3F0" stroke-width="2" fill="none" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{a.mahkota}}" hint-placeholder-val="{{ false }}">
      <path d="M5 32 Q24 12 43 32" stroke="#4E9A4A" stroke-width="2.4" fill="none" stroke-linecap="round"></path>
      <ellipse cx="12" cy="24" rx="4" ry="2" fill="#5FAE5A" transform="rotate(-40 12 24)"></ellipse>
      <ellipse cx="36" cy="24" rx="4" ry="2" fill="#5FAE5A" transform="rotate(40 36 24)"></ellipse>
      <circle cx="7" cy="31" r="5" fill="#F07F9A"></circle>
      <circle cx="16" cy="21.5" r="5" fill="#FFFBF3" stroke="#E2C79C" stroke-width="1"></circle>
      <circle cx="24" cy="18" r="5.4" fill="#B79CE0"></circle>
      <circle cx="32" cy="21.5" r="5" fill="#FFC83D"></circle>
      <circle cx="41" cy="31" r="5" fill="#F07F9A"></circle>
      <circle cx="7" cy="31" r="1.8" fill="#FFE6A8"></circle>
      <circle cx="16" cy="21.5" r="1.8" fill="#F59A33"></circle>
      <circle cx="24" cy="18" r="2" fill="#FFE6A8"></circle>
      <circle cx="32" cy="21.5" r="1.8" fill="#F59A33"></circle>
      <circle cx="41" cy="31" r="1.8" fill="#FFE6A8"></circle>
    </sc-if>
    <sc-if value="{{a.topiKoki}}" hint-placeholder-val="{{ false }}">
      <g transform="rotate(-8 24 26)">
        <path d="M12 33 V24 Q24 21 36 24 V33 Q24 30 12 33 Z" fill="#FFFFFF" stroke="#C9B89E" stroke-width="1.6" stroke-linejoin="round"></path>
        <path d="M17 31.6 V23 M24 31 V22 M31 31.6 V23" stroke="#E2D6C4" stroke-width="1.4" stroke-linecap="round"></path>
        <path d="M11.5 24.5 Q3 19 8 10 Q11 2 19 5 Q22 -2 30 3 Q38 0 40 8 Q46 15 36.5 24 Q24 20.5 11.5 24.5 Z" fill="#FFFFFF" stroke="#C9B89E" stroke-width="1.8" stroke-linejoin="round"></path>
        <path d="M19 6 Q21 14 18.5 21 M30 4.5 Q31.5 13 29.5 21" stroke="#E2D6C4" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
      </g>
    </sc-if>
    <sc-if value="{{a.dasiKupu}}" hint-placeholder-val="{{ false }}">
      <path d="M24 24 L7 14 L7 34 Z" fill="#E0453A" stroke="#B8352B" stroke-width="1.6" stroke-linejoin="round"></path>
      <path d="M24 24 L41 14 L41 34 Z" fill="#E0453A" stroke="#B8352B" stroke-width="1.6" stroke-linejoin="round"></path>
      <path d="M12 19 L17 24 L12 29 M36 19 L31 24 L36 29" stroke="#B8352B" stroke-width="1.3" fill="none" stroke-linecap="round"></path>
      <rect x="20" y="19.5" width="8" height="9" rx="2.5" fill="#B8352B"></rect>
    </sc-if>
    <sc-if value="{{a.syal}}" hint-placeholder-val="{{ false }}">
      <path d="M26 26 L27 45 L34 45 L33 25 Z" fill="#4E9A4A"></path>
      <path d="M31 24 L36 43 L42.5 41.5 L38 22.5 Z" fill="#5FAE5A"></path>
      <path d="M5 12 Q24 25 43 12 L43 21 Q24 35 5 21 Z" fill="#5FAE5A" stroke="#4E9A4A" stroke-width="1.2" stroke-linejoin="round"></path>
      <path d="M13 18.5 V25.5 M20 21 V28.5 M28 21 V28.5 M35 18.5 V25.5" stroke="#FFFBF3" stroke-width="2" stroke-linecap="round" opacity="0.85"></path>
    </sc-if>
    <sc-if value="{{a.baret}}" hint-placeholder-val="{{ false }}">
      <path d="M5 30 Q3 17 21 13 Q40 10 45 21 Q47 29 36 31 Q19 33.5 5 30 Z" fill="#C2492F"></path>
      <path d="M7 30.6 Q22 34 39 31" stroke="#9A3520" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
      <path d="M23 13 L24.5 6.5" stroke="#9A3520" stroke-width="3" stroke-linecap="round"></path>
      <path d="M14 17 Q25 14 36 16" stroke="#D9604A" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{a.jepitBunga}}" hint-placeholder-val="{{ false }}">
      <path d="M6 38 L42 30" stroke="#7FC8E8" stroke-width="3.4" stroke-linecap="round"></path>
      <ellipse cx="34" cy="33" rx="5" ry="2.4" fill="#5FAE5A" transform="rotate(20 34 33)"></ellipse>
      <circle cx="24" cy="12" r="6" fill="#F7A8C0"></circle>
      <circle cx="31.6" cy="17.6" r="6" fill="#F7A8C0"></circle>
      <circle cx="28.7" cy="26.4" r="6" fill="#F7A8C0"></circle>
      <circle cx="19.3" cy="26.4" r="6" fill="#F7A8C0"></circle>
      <circle cx="16.4" cy="17.6" r="6" fill="#F7A8C0"></circle>
      <circle cx="24" cy="20" r="4.6" fill="#FFC83D"></circle>
    </sc-if>
    <sc-if value="{{a.topiPenyihir}}" hint-placeholder-val="{{ false }}">
      <path d="M14 36 Q19 20 24 9 Q30 -2 43 3 Q33 6 31 14 Q31 26 34 35 Q24 33 14 36 Z" fill="#5E4A8A" stroke="#4B3B6E" stroke-width="1.4" stroke-linejoin="round"></path>
      <path d="M15.4 31.5 Q24 29.6 32.8 31" stroke="#FFC83D" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
      <path d="M3 38 Q24 30 45 38 Q24 45 3 38 Z" fill="#4B3B6E"></path>
      <path d="M25 16 L26.2 19.2 L29.6 19.4 L27 21.6 L27.8 25 L25 23.1 L22.2 25 L23 21.6 L20.4 19.4 L23.8 19.2 Z" fill="#FFC83D"></path>
    </sc-if>
    <sc-if value="{{a.headphone}}" hint-placeholder-val="{{ false }}">
      <path d="M11 30 Q11 8 24 8 Q37 8 37 30" stroke="#3B2716" stroke-width="4" fill="none" stroke-linecap="round"></path>
      <rect x="4" y="25" width="12" height="17" rx="5" fill="#2F86B8" stroke="#24709B" stroke-width="1.2"></rect>
      <rect x="32" y="25" width="12" height="17" rx="5" fill="#2F86B8" stroke="#24709B" stroke-width="1.2"></rect>
      <path d="M8 29 V38 M40 29 V38" stroke="#7FC8E8" stroke-width="2" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{a.tandukRusa}}" hint-placeholder-val="{{ false }}">
      <path d="M18 44 Q16 30 10 19 M13.6 29 Q7.6 28.4 3.6 24 M11.4 22.6 Q11.6 15 15 10" stroke="#B07A4F" stroke-width="4.4" fill="none" stroke-linecap="round"></path>
      <path d="M30 44 Q32 30 38 19 M34.4 29 Q40.4 28.4 44.4 24 M36.6 22.6 Q36.4 15 33 10" stroke="#B07A4F" stroke-width="4.4" fill="none" stroke-linecap="round"></path>
    </sc-if>
    <sc-if value="{{a.mahkotaRaja}}" hint-placeholder-val="{{ false }}">
      <path d="M8 39 L6 15 L16 23 L24 8 L32 23 L42 15 L40 39 Z" fill="#FFC83D" stroke="#C98F00" stroke-width="1.8" stroke-linejoin="round"></path>
      <path d="M8 39 L40 39 L40.6 32 L7.4 32 Z" fill="#F0B020"></path>
      <circle cx="24" cy="35.5" r="2.8" fill="#E0453A"></circle>
      <circle cx="14.5" cy="35.5" r="2" fill="#2F86B8"></circle>
      <circle cx="33.5" cy="35.5" r="2" fill="#2BB5A0"></circle>
      <circle cx="6" cy="15" r="2.6" fill="#FFE6A8" stroke="#C98F00" stroke-width="1"></circle>
      <circle cx="24" cy="8" r="2.8" fill="#FFE6A8" stroke="#C98F00" stroke-width="1"></circle>
      <circle cx="42" cy="15" r="2.6" fill="#FFE6A8" stroke="#C98F00" stroke-width="1"></circle>
    </sc-if>
''';

/// Gambar barang dan camilan per kode desain, lapisan di belakang kucing
/// (`Barang.dc.html`).
const roomItemBackSvgs = <String, String>{
  'kardus': r'''
          <ellipse cx="55" cy="79" rx="56" ry="4" fill="#7A4A1F" opacity="0.16"></ellipse>
          <rect x="8" y="10" width="94" height="22" rx="2" fill="#7E5228"></rect>
      ''',
  'bola': r'''
          <ellipse cx="18" cy="34" rx="14" ry="2.6" fill="#7A4A1F" opacity="0.16"></ellipse>
          <path d="M30 26 Q38 31 35 36" stroke="#E0565B" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          <g class="brg-anim" style="transform-origin: 18px 33px; animation: brgRock 2.8s ease-in-out infinite">
            <circle cx="18" cy="18" r="15" fill="#E0565B"></circle>
            <path d="M5 14 Q18 8 31 16 M4 21 Q18 16 32 24 M9 30 Q16 18 14 5 M22 32.5 Q27 20 24 4" stroke="#B23B44" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
            <ellipse cx="12" cy="10" rx="4" ry="2.4" fill="#FFFFFF" opacity="0.35" transform="rotate(-30 12 10)"></ellipse>
          </g>
      ''',
  'tikus': r'''
          <ellipse cx="23" cy="26" rx="18" ry="2.4" fill="#7A4A1F" opacity="0.16"></ellipse>
          <path d="M40 18 Q46 14 43 6" stroke="#E07A8A" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          <path d="M6 18 Q8 6 24 6 Q38 6 40 18 Q40 24 32 24 L12 24 Q6 24 6 18 Z" fill="#9C95AE"></path>
          <path d="M26 6 L26 1.5 M22 1.5 L30 1.5" stroke="#C99466" stroke-width="2.2" stroke-linecap="round"></path>
          <circle cx="14" cy="9" r="5" fill="#C2BBD3"></circle>
          <circle cx="14" cy="9" r="2.6" fill="#F2A7B5"></circle>
          <circle cx="10.5" cy="15" r="1.4" fill="#3B2716"></circle>
          <circle cx="6.5" cy="18.4" r="1.6" fill="#E07A8A"></circle>
      ''',
  'karpet': r'''
          <ellipse cx="92" cy="33" rx="91" ry="25" fill="#7A4A1F" opacity="0.12"></ellipse>
          <ellipse cx="92" cy="30" rx="88" ry="24" fill="#E58A62"></ellipse>
          <ellipse cx="92" cy="30" rx="80" ry="20.5" fill="none" stroke="#C2492F" stroke-width="1.6" stroke-dasharray="3 6" opacity="0.55"></ellipse>
          <ellipse cx="92" cy="30" rx="66" ry="16.5" fill="#F4B48C"></ellipse>
          <ellipse cx="92" cy="30" rx="50" ry="12.5" fill="#E58A62"></ellipse>
          <ellipse cx="92" cy="30" rx="32" ry="8" fill="#F7C9A3"></ellipse>
      ''',
  'kasur': r'''
          <ellipse cx="75" cy="66" rx="74" ry="9" fill="#7A4A1F" opacity="0.14"></ellipse>
          <ellipse cx="75" cy="38" rx="72" ry="26" fill="#6FB8DD"></ellipse>
          <ellipse cx="75" cy="33" rx="62" ry="18" fill="#8FCBEA"></ellipse>
          <ellipse cx="75" cy="38" rx="54" ry="15" fill="#FBE7C6"></ellipse>
          <ellipse cx="75" cy="40" rx="44" ry="10" fill="#F4D7A8" opacity="0.6"></ellipse>
      ''',
  'tiang': r'''
          <ellipse cx="25" cy="149" rx="26" ry="3.5" fill="#7A4A1F" opacity="0.16"></ellipse>
          <rect x="1" y="136" width="48" height="14" rx="5" fill="#B07A4F"></rect>
          <rect x="14" y="14" width="22" height="124" fill="#D8A86F"></rect>
          <path d="M14 22 H36 M14 30 H36 M14 38 H36 M14 46 H36 M14 54 H36 M14 62 H36 M14 70 H36 M14 78 H36 M14 86 H36 M14 94 H36 M14 102 H36 M14 110 H36 M14 118 H36 M14 126 H36 M14 134 H36" stroke="#B78553" stroke-width="2" opacity="0.8"></path>
          <path d="M20 64 L22 76 M24 63 L26 75 M28 65 L30 77" stroke="#8E5A30" stroke-width="1.4" stroke-linecap="round" opacity="0.7"></path>
          <rect x="3" y="4" width="44" height="13" rx="5" fill="#B07A4F"></rect>
          <rect x="7" y="1" width="36" height="6" rx="3" fill="#F7E8CE"></rect>
          <path d="M42 17 L42 42" stroke="#6B4F3A" stroke-width="1.4"></path>
          <circle cx="42" cy="46" r="5" fill="#F59A33"></circle>
      ''',
  'akuarium': r'''
          <ellipse cx="46" cy="87" rx="46" ry="3.5" fill="#7A4A1F" opacity="0.16"></ellipse>
          <rect x="8" y="62" width="76" height="25" rx="4" fill="#B07A4F"></rect>
          <path d="M8 74 H84" stroke="#8E5A30" stroke-width="1.6"></path>
          <circle cx="30" cy="80" r="2" fill="#8E5A30"></circle>
          <circle cx="62" cy="80" r="2" fill="#8E5A30"></circle>
          <rect x="4" y="8" width="84" height="58" rx="8" fill="#CFEFFA" stroke="#2F86B8" stroke-width="3"></rect>
          <rect x="7" y="17" width="78" height="46" rx="5" fill="#9ED9F2"></rect>
          <path d="M7 55 Q20 49 34 54 Q50 49 64 54 Q76 50 85 54 L85 58 Q85 63 80 63 L12 63 Q7 63 7 58 Z" fill="#E6C38F"></path>
          <path d="M20 56 Q15 42 22 28 M25 56 Q31 44 26 34 M70 56 Q74 46 69 38" stroke="#4E9A4A" stroke-width="3" fill="none" stroke-linecap="round"></path>
          <circle cx="56" cy="30" r="2" fill="none" stroke="#FFFFFF" stroke-width="1.2"></circle>
          <circle cx="60" cy="23" r="1.4" fill="none" stroke="#FFFFFF" stroke-width="1.2"></circle>
          <g style="transform-box: fill-box; transform-origin: center; animation: brgFish 5s ease-in-out infinite">
            <path d="M23 36 L16 31.5 L16 40.5 Z" fill="#F59A33"></path>
            <ellipse cx="30" cy="36" rx="8" ry="5" fill="#F59A33"></ellipse>
            <circle cx="34" cy="35" r="1.2" fill="#3B2716"></circle>
          </g>
          <g style="transform-box: fill-box; transform-origin: center; animation: brgFish2 4s ease-in-out infinite">
            <path d="M68 46 L73 43 L73 49 Z" fill="#FFC83D"></path>
            <ellipse cx="63" cy="46" rx="5.5" ry="3.6" fill="#FFC83D"></ellipse>
            <circle cx="60.4" cy="45.4" r="0.9" fill="#3B2716"></circle>
          </g>
          <rect x="2" y="3" width="88" height="8" rx="3" fill="#2F86B8"></rect>
          <path d="M10 22 L10 50" stroke="#FFFFFF" stroke-width="2" opacity="0.5" stroke-linecap="round"></path>
      ''',
  'rumah': r'''
          <ellipse cx="61" cy="129" rx="60" ry="4" fill="#7A4A1F" opacity="0.16"></ellipse>
          <rect x="10" y="46" width="102" height="82" rx="6" fill="#EDBE8C"></rect>
          <path d="M10 66 H112 M10 86 H112 M10 106 H112" stroke="#D59E67" stroke-width="2"></path>
          <path d="M4 52 L61 8 L118 52 Z" fill="#C2492F" stroke="#C2492F" stroke-width="6" stroke-linejoin="round"></path>
          <path d="M4 52 L61 8 L118 52" stroke="#9A3520" stroke-width="3" fill="none" stroke-linejoin="round" stroke-linecap="round"></path>
          <circle cx="61" cy="34" r="8" fill="#FFF4E2" stroke="#9A3520" stroke-width="2"></circle>
          <path d="M61 26 V42 M53 34 H69" stroke="#9A3520" stroke-width="1.6"></path>
          <path d="M35 128 L35 98 A26 26 0 0 1 87 98 L87 128 Z" fill="#5E3B22"></path>
          <rect x="44" y="58" width="34" height="9" rx="4.5" fill="#FFFBF3" stroke="#D59E67" stroke-width="1.4"></rect>
      ''',
  'lukisan': r'''
          <path d="M20 14 L36 2 L52 14" stroke="#6B4F3A" stroke-width="1.4" fill="none"></path>
          <circle cx="36" cy="2" r="2" fill="#6B4F3A"></circle>
          <rect x="2" y="12" width="68" height="52" rx="4" fill="#B07A4F"></rect>
          <rect x="6" y="16" width="60" height="44" rx="2" fill="#E6C38F"></rect>
          <rect x="9" y="19" width="54" height="38" fill="#BFE7F7"></rect>
          <path d="M9 50 Q18 45 27 50 Q36 55 45 50 Q54 45 63 50 L63 57 L9 57 Z" fill="#8FD3F0"></path>
          <path d="M22 37 L13 30 L13 44 Z" fill="#F59A33"></path>
          <ellipse cx="34" cy="37" rx="14" ry="8.5" fill="#F59A33"></ellipse>
          <path d="M28 30 Q30 37 28 44 M33 29 Q35 37 33 45" stroke="#C9650C" stroke-width="1.8" fill="none" stroke-linecap="round"></path>
          <circle cx="42" cy="35" r="1.9" fill="#3B2716"></circle>
          <circle cx="52" cy="28" r="2" fill="none" stroke="#FFFFFF" stroke-width="1.2"></circle>
          <circle cx="56" cy="23" r="1.3" fill="none" stroke="#FFFFFF" stroke-width="1.2"></circle>
      ''',
  'jam': r'''
          <g style="transform-origin: 26px 46px; animation: brgSwing 1.4s ease-in-out infinite">
            <path d="M26 46 Q22 62 27 77" stroke="#3B2716" stroke-width="5" fill="none" stroke-linecap="round"></path>
            <circle cx="27" cy="80" r="4.5" fill="#F59A33"></circle>
          </g>
          <path d="M8 18 L10 2 L22 10 Z" fill="#3B2716" stroke="#3B2716" stroke-width="3" stroke-linejoin="round"></path>
          <path d="M44 18 L42 2 L30 10 Z" fill="#3B2716" stroke="#3B2716" stroke-width="3" stroke-linejoin="round"></path>
          <path d="M11 13 L12 6 L17 10 Z M41 13 L40 6 L35 10 Z" fill="#F07F6A"></path>
          <circle cx="26" cy="27" r="22" fill="#3B2716"></circle>
          <circle cx="26" cy="27" r="17.5" fill="#FFFBF3"></circle>
          <path d="M26 12 V15 M26 39 V42 M11 27 H14 M38 27 H41" stroke="#3B2716" stroke-width="2" stroke-linecap="round"></path>
          <path d="M26 27 L26 17 M26 27 L33 31" stroke="#3B2716" stroke-width="2.4" stroke-linecap="round"></path>
          <circle cx="26" cy="27" r="2" fill="#F59A33"></circle>
      ''',
  'rak': r'''
          <path d="M14 13 L14 32 L30 13 Z" fill="#8E5A30"></path>
          <path d="M90 13 L90 32 L74 13 Z" fill="#8E5A30"></path>
          <rect x="0" y="4" width="104" height="10" rx="3" fill="#B07A4F"></rect>
          <rect x="0" y="4" width="104" height="4" rx="2" fill="#C99466"></rect>
          <rect x="84" y="-8" width="13" height="12" rx="2" fill="#C8673F"></rect>
          <g class="brg-anim" style="transform-origin: 90.5px -8px; animation: brgSway 3.4s ease-in-out infinite">
            <path d="M90.5 -8 Q86 -16 84 -20 M90.5 -8 Q91 -17 92 -22 M90.5 -8 Q95 -15 98 -18" stroke="#4E9A4A" stroke-width="2.6" fill="none" stroke-linecap="round"></path>
          </g>
      ''',
  'terowongan': r'''
          <ellipse cx="78" cy="60" rx="74" ry="4" fill="#7A4A1F" opacity="0.14"></ellipse>
          <path d="M16 12 H140 A10 22 0 0 1 140 56 H16 Z" fill="#B79CE0"></path>
          <path d="M44 12 Q50 34 44 56 M72 12 Q78 34 72 56 M100 12 Q106 34 100 56 M128 12 Q134 34 128 56" stroke="#9C82CC" stroke-width="2.2" fill="none"></path>
          <ellipse cx="16" cy="34" rx="12" ry="22" fill="#9C82CC"></ellipse>
          <ellipse cx="16" cy="34" rx="8.5" ry="18" fill="#3E2F5C"></ellipse>
      ''',
  'pancingan': r'''
          <ellipse cx="34" cy="66" rx="30" ry="3" fill="#7A4A1F" opacity="0.14"></ellipse>
          <path d="M6 62 Q30 42 58 18" stroke="#B07A4F" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
          <circle cx="6" cy="62" r="3.6" fill="#8E5A30"></circle>
          <path d="M58 18 Q68 24 64 38" stroke="#6B4F3A" stroke-width="1.2" fill="none"></path>
          <g class="brg-anim" style="transform-origin: 64px 38px; animation: brgFeather 1.3s ease-in-out infinite alternate">
            <ellipse cx="60" cy="48" rx="3.4" ry="10" fill="#F07F9A" transform="rotate(20 60 48)"></ellipse>
            <ellipse cx="66" cy="49" rx="3.4" ry="11" fill="#7FC8E8" transform="rotate(-10 66 49)"></ellipse>
            <ellipse cx="71" cy="46" rx="3" ry="9" fill="#FFC83D" transform="rotate(-35 71 46)"></ellipse>
            <circle cx="64" cy="38.5" r="2.4" fill="#C2492F"></circle>
          </g>
      ''',
  'bantalIkan': r'''
          <ellipse cx="64" cy="51" rx="60" ry="4.5" fill="#7A4A1F" opacity="0.14"></ellipse>
          <path d="M110 28 L128 11 L124 28 L128 45 Z" fill="#5FB2DE" stroke="#4FA3C9" stroke-width="1.4" stroke-linejoin="round"></path>
          <path d="M60 9 Q72 -2 88 10 Z" fill="#5FB2DE"></path>
          <path d="M8 29 Q26 5 76 8 Q102 10 112 28 Q102 46 76 48 Q26 52 8 29 Z" fill="#7FC8E8" stroke="#4FA3C9" stroke-width="1.6"></path>
          <path d="M46 14 Q52 28 46 44 M62 12 Q68 28 62 46 M78 12 Q84 28 78 46" stroke="#A8DDF2" stroke-width="2.2" fill="none" stroke-linecap="round"></path>
          <circle cx="26" cy="25" r="5" fill="#FFFFFF"></circle>
          <circle cx="27" cy="25.5" r="2.6" fill="#3B2716"></circle>
          <path d="M13 33 Q17 36 21 33" stroke="#3B2716" stroke-width="1.6" fill="none" stroke-linecap="round"></path>
          <path d="M16 40 Q60 50 104 38" stroke="#FFFFFF" stroke-width="1.4" stroke-dasharray="3 4" fill="none" opacity="0.7"></path>
      ''',
  'sofaMini': r'''
          <ellipse cx="70" cy="83" rx="68" ry="4" fill="#7A4A1F" opacity="0.14"></ellipse>
          <rect x="10" y="6" width="120" height="48" rx="18" fill="#E58A62"></rect>
          <path d="M42 12 V44 M70 10 V44 M98 12 V44" stroke="#D9704A" stroke-width="2" opacity="0.7"></path>
          <circle cx="42" cy="28" r="1.8" fill="#C2603F"></circle>
          <circle cx="70" cy="28" r="1.8" fill="#C2603F"></circle>
          <circle cx="98" cy="28" r="1.8" fill="#C2603F"></circle>
          <rect x="14" y="44" width="112" height="24" rx="9" fill="#F4B48C"></rect>
          <path d="M70 46 V66" stroke="#E58A62" stroke-width="1.6" opacity="0.7"></path>
          <rect x="6" y="64" width="128" height="14" rx="5" fill="#C2603F"></rect>
          <path d="M14 78 V84 M126 78 V84" stroke="#8E5A30" stroke-width="4" stroke-linecap="round"></path>
      ''',
  'jendelaBurung': r'''
          <rect x="0" y="0" width="100" height="90" rx="8" fill="#FFFBF3" stroke="#E2C79C" stroke-width="1.5"></rect>
          <rect x="7" y="7" width="86" height="76" rx="5" fill="#BFE7F7"></rect>
          <ellipse cx="28" cy="22" rx="12" ry="5" fill="#FFFFFF"></ellipse>
          <ellipse cx="36" cy="19" rx="7" ry="4" fill="#FFFFFF"></ellipse>
          <path d="M7 62 Q50 56 93 64" stroke="#8E5A30" stroke-width="3.4" fill="none" stroke-linecap="round"></path>
          <ellipse cx="28" cy="57" rx="5" ry="2.4" fill="#5FAE5A" transform="rotate(-20 28 57)"></ellipse>
          <ellipse cx="80" cy="60" rx="5" ry="2.4" fill="#5FAE5A" transform="rotate(20 80 60)"></ellipse>
          <g class="brg-anim" style="animation: brgHop 2.6s ease-in-out infinite">
            <path d="M52 54 L45 51 L46 57 Z" fill="#7A5A3E"></path>
            <ellipse cx="58" cy="53" rx="8" ry="6.5" fill="#9C7450"></ellipse>
            <ellipse cx="60" cy="56" rx="5" ry="3.8" fill="#F4B48C"></ellipse>
            <circle cx="64" cy="46" r="5" fill="#9C7450"></circle>
            <path d="M68.5 45.2 L72.5 46.6 L68.5 48 Z" fill="#FFC83D"></path>
            <circle cx="65.4" cy="45" r="1.1" fill="#3B2716"></circle>
            <path d="M57 59 V62 M61 59 V62" stroke="#8E5A30" stroke-width="1" stroke-linecap="round"></path>
          </g>
          <rect x="48.5" y="7" width="3" height="76" fill="#FFFBF3"></rect>
          <rect x="-4" y="86" width="108" height="10" rx="3" fill="#B07A4F"></rect>
          <rect x="-4" y="86" width="108" height="3.5" rx="1.5" fill="#C99466"></rect>
      ''',
  'lampuBulan': r'''
          <circle class="brg-anim" cx="30" cy="32" r="28" fill="#FFE6A8" style="transform-origin: 30px 32px; animation: brgGlow 3s ease-in-out infinite"></circle>
          <path d="M30 0 V10" stroke="#6B4F3A" stroke-width="1.4"></path>
          <path d="M36 10 A22 22 0 1 0 52 44 A17 17 0 1 1 36 10 Z" fill="#FFE6A8" stroke="#E8C66A" stroke-width="1.6" stroke-linejoin="round"></path>
          <circle cx="24" cy="38" r="2.4" fill="#F2D48A"></circle>
          <circle cx="20" cy="28" r="1.6" fill="#F2D48A"></circle>
          <path d="M48 16 L49 19 L52 20 L49 21 L48 24 L47 21 L44 20 L47 19 Z" fill="#FFC83D"></path>
          <circle cx="54" cy="30" r="1.4" fill="#FFC83D"></circle>
      ''',
  'hammock': r'''
          <circle cx="8" cy="5" r="4.5" fill="#BFE7F7" stroke="#5FB2DE" stroke-width="1.4"></circle>
          <circle cx="112" cy="5" r="4.5" fill="#BFE7F7" stroke="#5FB2DE" stroke-width="1.4"></circle>
          <path d="M8 8 L26 34 M112 8 L94 34" stroke="#B07A4F" stroke-width="2.4" stroke-linecap="round"></path>
          <path d="M22 32 Q60 72 98 32 Q60 46 22 32 Z" fill="#F4B48C" stroke="#E58A62" stroke-width="1.4" stroke-linejoin="round"></path>
          <path d="M34 38 Q60 48 86 38" stroke="#FFFBF3" stroke-width="2.4" fill="none" opacity="0.8"></path>
      ''',
  'mangkuk': r'''
          <ellipse cx="27" cy="27.5" rx="24" ry="3" fill="#7A4A1F" opacity="0.16"></ellipse>
          <path d="M4 8 L50 8 L45 25 Q27 29 9 25 Z" fill="#2F86B8"></path>
          <path d="M17 16 Q22 12.5 27 16 Q22 19.5 17 16 Z M27 16 L31 13.4 L31 18.6 Z" fill="#BFE7F7"></path>
          <ellipse cx="27" cy="8" rx="23" ry="4.6" fill="#5FB2DE"></ellipse>
          <sc-if value="{{penuh}}" hint-placeholder-val="{{ true }}">
            <ellipse cx="27" cy="7.4" rx="18" ry="3.8" fill="#B07A4F"></ellipse>
            <circle cx="19" cy="6" r="1.6" fill="#8E5A30"></circle>
            <circle cx="27" cy="5" r="1.7" fill="#D9A066"></circle>
            <circle cx="35" cy="6.4" r="1.5" fill="#8E5A30"></circle>
            <circle cx="31" cy="4.6" r="1.3" fill="#8E5A30"></circle>
            <circle cx="23" cy="4.4" r="1.3" fill="#D9A066"></circle>
          </sc-if>
          <sc-if value="{{kosong}}" hint-placeholder-val="{{ false }}">
            <ellipse cx="27" cy="8.6" rx="18.5" ry="3.4" fill="#1F5E80"></ellipse>
            <circle cx="22" cy="9" r="1.1" fill="#B07A4F"></circle>
            <circle cx="31" cy="8.4" r="0.9" fill="#B07A4F"></circle>
          </sc-if>
      ''',
  'ikanAsin': r'''
          <path d="M3 11 Q14 1 30 7 L41 2 L38 11 L41 20 L30 15 Q14 21 3 11 Z" fill="#D9C08E" stroke="#A88A55" stroke-width="1.4" stroke-linejoin="round"></path>
          <path d="M13 6 Q16 11 13 16" stroke="#A88A55" stroke-width="1.3" fill="none"></path>
          <path d="M18 7.5 L18 14.5 M22 7.5 L22 14.5 M26 8.2 L26 13.8" stroke="#BFA06A" stroke-width="1.2" stroke-linecap="round"></path>
          <circle cx="8.6" cy="10" r="1.6" fill="#3B2716"></circle>
          <circle cx="20" cy="4" r="0.9" fill="#FFFFFF"></circle>
          <circle cx="28" cy="17.5" r="0.8" fill="#FFFFFF"></circle>
      ''',
  'susu': r'''
          <ellipse cx="21" cy="13" rx="19" ry="6" fill="#FFFBF3" stroke="#CDB48C" stroke-width="1.4"></ellipse>
          <ellipse cx="21" cy="11.5" rx="13" ry="3.8" fill="#F2E9DA"></ellipse>
          <ellipse cx="21" cy="11.3" rx="11.5" ry="3.1" fill="#FFFFFF"></ellipse>
          <path d="M35 1 Q37.4 4.6 35 6.2 Q32.6 4.6 35 1 Z" fill="#FFFFFF" stroke="#D9CFC0" stroke-width="1"></path>
      ''',
  'tuna': r'''
          <rect x="3" y="8" width="26" height="20" rx="3" fill="#B8C2CC"></rect>
          <rect x="3" y="13" width="26" height="10" fill="#2F86B8"></rect>
          <path d="M9 18 Q14 14.4 19 18 Q14 21.6 9 18 Z M19 18 L23 15.4 L23 20.6 Z" fill="#FFFFFF"></path>
          <ellipse cx="16" cy="8" rx="13" ry="3.6" fill="#D9E0E6" stroke="#9AA6B2" stroke-width="1"></ellipse>
          <ellipse cx="20" cy="7.4" rx="4" ry="1.6" fill="none" stroke="#9AA6B2" stroke-width="1.4"></ellipse>
          <path d="M3 25 Q16 30 29 25" stroke="#9AA6B2" stroke-width="1.2" fill="none"></path>
      ''',
  'biskuit': r'''
          <g fill="#D9A066" stroke="#B07A4F" stroke-width="1" stroke-linejoin="round">
            <path d="M3 16 Q9 9 17 12 L22 9 L21 15 L22 21 L17 18 Q9 22 3 16 Z"></path>
            <path d="M20 9 Q27 2 35 5 L40 2 L39 8 L40 14 L35 11 Q27 14 20 9 Z"></path>
            <path d="M22 20 Q28 15 35 17 L39 14 L38.5 19.5 L39.5 24 L35 21 Q28 24 22 20 Z"></path>
          </g>
          <circle cx="7" cy="15" r="0.9" fill="#8E5A30"></circle>
          <circle cx="24" cy="8" r="0.9" fill="#8E5A30"></circle>
          <circle cx="26" cy="19" r="0.9" fill="#8E5A30"></circle>
      ''',
  'puding': r'''
          <ellipse cx="20" cy="29" rx="19" ry="4.5" fill="#FFFBF3" stroke="#CDB48C" stroke-width="1.2"></ellipse>
          <g class="brg-anim" style="transform-origin: 20px 28px; animation: brgWobble 2.2s ease-in-out infinite">
            <path d="M6 28 Q5 10 12 7 Q20 3 28 7 Q35 10 34 28 Z" fill="#F4B48C"></path>
            <path d="M6.6 15 Q20 19 33.4 15 L33.8 19 Q20 23 6.4 19 Z" fill="#E58A62" opacity="0.55"></path>
            <path d="M12.5 7.5 Q20 2 27.5 7.5 Q20 10.5 12.5 7.5 Z" fill="#C2603F"></path>
            <path d="M15.5 4.6 Q19 1.6 22.5 4.6 Q19 7 15.5 4.6 Z M22.5 4.6 L25 2.8 L25 6.4 Z" fill="#FFFBF3"></path>
            <path d="M10 12 Q9 18 10 24" stroke="#FFFFFF" stroke-width="1.6" fill="none" stroke-linecap="round" opacity="0.7"></path>
          </g>
      ''',
};

/// Lapisan di depan kucing: barang yang kucingnya duduk atau tidur di dalamnya
/// (`Barang.dc.html`).
const roomItemFrontSvgs = <String, String>{
  'kardus': r'''
          <rect x="6" y="24" width="98" height="56" rx="3" fill="#C8955A"></rect>
          <rect x="50" y="24" width="10" height="56" fill="#E6C38F"></rect>
          <path d="M6 24 L104 24" stroke="#9E6C37" stroke-width="1.6"></path>
          <path d="M6 24 L-4 10 L18 8 L26 24 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1.4" stroke-linejoin="round"></path>
          <path d="M104 24 L114 10 L92 8 L84 24 Z" fill="#DDB07A" stroke="#9E6C37" stroke-width="1.4" stroke-linejoin="round"></path>
          <g fill="#9E6C37" opacity="0.45" transform="translate(28 54)"><ellipse cx="0" cy="3" rx="5" ry="4.3"></ellipse><circle cx="-5.2" cy="-3.6" r="2"></circle><circle cx="-1.8" cy="-6.6" r="2"></circle><circle cx="1.8" cy="-6.6" r="2"></circle><circle cx="5.2" cy="-3.6" r="2"></circle></g>
          <path d="M84 64 V46 M79 51 L84 46 L89 51" stroke="#9E6C37" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" opacity="0.45"></path>
      ''',
  'kasur': r'''
          <path d="M3 38 A72 26 0 0 0 147 38 L147 47 A72 26 0 0 1 3 47 Z" fill="#4E9CC6"></path>
          <path d="M3 38 A72 26 0 0 0 147 38 L129 38 A54 15 0 0 1 21 38 Z" fill="#6FB8DD"></path>
          <path d="M14 46 A62 19 0 0 0 136 46" stroke="#FFFFFF" stroke-width="1.6" stroke-dasharray="3 5" fill="none" opacity="0.65"></path>
      ''',
  'catnip': r'''
          <ellipse cx="26" cy="71" rx="21" ry="3" fill="#7A4A1F" opacity="0.16"></ellipse>
          <g class="brg-anim" style="transform-origin: 26px 37px; animation: brgSway 3.2s ease-in-out infinite">
            <path d="M26 36 Q14 26 16 10 Q26 18 26 36 Z" fill="#4E9A4A"></path>
            <path d="M26 36 Q38 24 38 8 Q27 18 26 36 Z" fill="#5FAE5A"></path>
            <path d="M26 36 Q22 18 28 2 Q32 20 26 36 Z" fill="#6CC067"></path>
            <path d="M24 37 Q8 35 4 22 Q18 22 24 37 Z" fill="#5FAE5A"></path>
            <path d="M28 37 Q44 35 48 22 Q34 22 28 37 Z" fill="#4E9A4A"></path>
          </g>
          <path d="M10 40 L42 40 L38 70 L14 70 Z" fill="#C8673F"></path>
          <rect x="6" y="34" width="40" height="9" rx="3" fill="#DB7B4E"></rect>
          <g fill="#F4B48C" transform="translate(26 56)"><ellipse cx="0" cy="2.4" rx="3.6" ry="3"></ellipse><circle cx="-3.8" cy="-2.4" r="1.4"></circle><circle cx="-1.3" cy="-4.6" r="1.4"></circle><circle cx="1.3" cy="-4.6" r="1.4"></circle><circle cx="3.8" cy="-2.4" r="1.4"></circle></g>
      ''',
  'rumah': r'''
          <rect x="30" y="119" width="62" height="10" rx="3" fill="#D59E67"></rect>
      ''',
  'terowongan': r'''
          <path d="M34 12 H140 A10 22 0 0 1 140 56 H34 Q39 34 34 12 Z" fill="#B79CE0"></path>
          <path d="M44 12 Q50 34 44 56 M72 12 Q78 34 72 56 M100 12 Q106 34 100 56 M128 12 Q134 34 128 56" stroke="#9C82CC" stroke-width="2.2" fill="none"></path>
          <path d="M40 17 H134" stroke="#D3C3EE" stroke-width="3" stroke-linecap="round" opacity="0.8"></path>
          <g fill="#9C82CC" opacity="0.6" transform="translate(112 40) scale(0.7)"><ellipse cx="0" cy="3" rx="5" ry="4.3"></ellipse><circle cx="-5.2" cy="-3.6" r="2"></circle><circle cx="-1.8" cy="-6.6" r="2"></circle><circle cx="1.8" cy="-6.6" r="2"></circle><circle cx="5.2" cy="-3.6" r="2"></circle></g>
      ''',
  'sofaMini': r'''
          <rect x="0" y="30" width="24" height="46" rx="11" fill="#D9704A"></rect>
          <rect x="116" y="30" width="24" height="46" rx="11" fill="#D9704A"></rect>
          <path d="M5 36 Q12 32 19 36 M121 36 Q128 32 135 36" stroke="#E58A62" stroke-width="2" fill="none" stroke-linecap="round"></path>
      ''',
  'monstera': r'''
          <ellipse cx="35" cy="107" rx="22" ry="3" fill="#7A4A1F" opacity="0.16"></ellipse>
          <g class="brg-anim" style="transform-origin: 35px 82px; animation: brgSway 4.2s ease-in-out infinite">
            <path d="M35 82 Q30 60 14 50 M35 82 Q38 56 52 40 M35 82 Q34 50 32 26" stroke="#3F7A3A" stroke-width="2.4" fill="none" stroke-linecap="round"></path>
            <path d="M14 50 Q0 46 2 32 Q6 20 20 26 Q30 32 24 46 Q20 52 14 50 Z" fill="#4E9A4A"></path>
            <path d="M52 40 Q66 42 68 30 Q66 16 52 20 Q42 24 46 36 Q48 41 52 40 Z" fill="#5FAE5A"></path>
            <path d="M32 26 Q18 22 20 10 Q24 0 34 2 Q46 4 44 16 Q42 26 32 26 Z" fill="#3F8A44"></path>
            <path d="M14 48 Q12 36 8 30 M8 37 L15 40 M11 44 L18 44 M52 38 Q55 28 62 22 M60 30 L54 32 M64 26 L56 26 M32 24 Q32 12 34 4 M25 12 L31 15 M42 10 L35 14" stroke="#2F6E34" stroke-width="1.4" fill="none" stroke-linecap="round"></path>
          </g>
          <path d="M20 84 H50 L46 108 H24 Z" fill="#C8673F"></path>
          <rect x="17" y="80" width="36" height="7" rx="3" fill="#DB7B4E"></rect>
      ''',
  'hammock': r'''
          <path d="M22 32 Q60 72 98 32 Q60 58 22 32 Z" fill="#E58A62"></path>
          <path d="M30 40 Q60 62 90 40" stroke="#FFFBF3" stroke-width="2" fill="none" stroke-dasharray="3 4" opacity="0.8"></path>
      ''',
};

/// viewBox tiap gambar barang dan camilan: (x, y, lebar, tinggi).
const roomItemViewBoxes = <String, (double, double, double, double)>{
  'kardus': (-6, 0, 122, 82),
  'bola': (0, 0, 36, 36),
  'tikus': (0, 0, 46, 28),
  'karpet': (0, 0, 184, 60),
  'kasur': (0, 0, 150, 76),
  'catnip': (0, 0, 52, 74),
  'tiang': (0, 0, 50, 152),
  'akuarium': (0, 0, 92, 90),
  'rumah': (0, 0, 122, 132),
  'lukisan': (0, 0, 72, 66),
  'jam': (0, 0, 52, 86),
  'rak': (0, 0, 104, 34),
  'terowongan': (0, 0, 152, 64),
  'pancingan': (0, 0, 80, 70),
  'bantalIkan': (0, 0, 130, 56),
  'sofaMini': (0, 0, 140, 86),
  'monstera': (0, 0, 70, 110),
  'jendelaBurung': (0, 0, 100, 96),
  'lampuBulan': (0, 0, 60, 60),
  'hammock': (0, 0, 120, 70),
  'mangkuk': (0, 0, 54, 30),
  'ikanAsin': (0, 0, 46, 22),
  'susu': (0, 0, 42, 20),
  'tuna': (0, 0, 32, 30),
  'biskuit': (0, 0, 44, 24),
  'puding': (0, 0, 40, 34),
};

/// Jendela dinding kamar, viewBox -8 0 140 134 (`Kamar.dc.html`).
const roomWindowSvg = r'''
      <rect x="0" y="0" width="124" height="124" rx="10" fill="#FFFBF3"></rect>
      <rect x="8" y="8" width="108" height="108" rx="6" fill="#BFE7F7"></rect>
      <circle cx="90" cy="34" r="12" fill="#FFE6A8"></circle>
      <ellipse cx="38" cy="36" rx="16" ry="7" fill="#FFFFFF"></ellipse>
      <ellipse cx="50" cy="32" rx="11" ry="7" fill="#FFFFFF"></ellipse>
      <path d="M8 98 Q40 78 70 94 Q96 82 116 94 V116 H8 Z" fill="#9ED39A"></path>
      <rect x="59" y="8" width="6" height="108" fill="#FFFBF3"></rect>
      <rect x="8" y="59" width="108" height="6" fill="#FFFBF3"></rect>
      <rect x="-6" y="118" width="136" height="10" rx="4" fill="#B07A4F"></rect>
      <path d="M-8 0 Q8 50 -2 118 L-8 118 Z" fill="#F4B48C"></path>
      <path d="M132 0 Q116 50 126 118 L132 118 Z" fill="#F4B48C"></path>
''';

/// Bidang cahaya dan goresan lantai kamar, viewBox 0 0 390 844
/// (`Kamar.dc.html`).
const roomFloorDecorSvg = r'''
    <path d="M44 426 L156 426 L214 566 L74 566 Z" fill="#FFFFFF" opacity="0.18"></path>
    <path d="M190 436 L196 470 M290 452 L296 486 M120 476 L124 500" stroke="#D4A971" stroke-width="2" opacity="0.5"></path>
''';

/// Tanda lesu di atas kucing, viewBox 0 0 48 52 (`TandaLesu.dc.html`).
const sadMarkSvg = r'''
    <circle cx="11" cy="48" r="2.8" fill="#EEF2F7" stroke="#6E86A8" stroke-width="1.6"></circle>
    <circle cx="17" cy="41" r="4" fill="#EEF2F7" stroke="#6E86A8" stroke-width="1.8"></circle>
    <circle cx="28" cy="20" r="18" fill="#EEF2F7" stroke="#6E86A8" stroke-width="2"></circle>
    <sc-if value="{{isLapar}}" hint-placeholder-val="{{ true }}">
      <path d="M16 20 H35 M21 14.5 L23.5 20 L21 25.5 M26 13.5 L28.5 20 L26 26.5 M31 14.5 L33 20 L31 25.5 M16 20 L12.5 16 M16 20 L12.5 24" stroke="#6E86A8" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"></path>
      <circle cx="38.6" cy="20" r="3.4" fill="none" stroke="#6E86A8" stroke-width="2"></circle>
      <circle cx="39.4" cy="19.4" r="0.9" fill="#6E86A8"></circle>
    </sc-if>
    <sc-if value="{{isSedih}}" hint-placeholder-val="{{ false }}">
      <path d="M17 18 Q17 11 24 11 Q27 6 33 9 Q39 9 39 15 Q42 19 37 22 L20 22 Q15 22 17 18 Z" fill="#B9C7DA"></path>
      <path d="M22 26 L20.5 30 M28 26 L26.5 30 M34 26 L32.5 30" stroke="#6E86A8" stroke-width="2" stroke-linecap="round"></path>
    </sc-if>
''';
