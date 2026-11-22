// Isi <svg> desain Gang Depan (docs/design/gang-depan/project), disalin
// utuh. Jangan diketik ulang: tulis ulang dengan
// tool/design/make_lane_svg.py. Dijaga design_sync_test.

library;

/// Latar gang: langit, rumah belakang, tanah, warung, depan rumah, dan pemandangan hangat di balik pintu pulang (`LatarGang.dc.html`). viewBox 0 0 390 652.
const laneBackSvg = r'''<defs>
<linearGradient id="lg-langit" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#A9DDF5"></stop><stop offset="1" stop-color="#E4F5EC"></stop></linearGradient>
<linearGradient id="lg-tanah" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E0C394"></stop><stop offset="0.35" stop-color="#E8CFA6"></stop><stop offset="1" stop-color="#EED9B4"></stop></linearGradient>
<linearGradient id="lg-plester" x1="1" y1="0" x2="0" y2="0"><stop offset="0" stop-color="#F6DAB5"></stop><stop offset="1" stop-color="#FCE6C8"></stop></linearGradient>
<linearGradient id="lg-kayu" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#BD8858"></stop><stop offset="1" stop-color="#CF9C6C"></stop></linearGradient>
<radialGradient id="lg-hangat" cx="0.5" cy="0.45" r="0.6"><stop offset="0" stop-color="#FFE39A"></stop><stop offset="1" stop-color="#FCE6C8"></stop></radialGradient>
<clipPath id="lg-tanahc"><polygon points="153.5,287.5 236.5,287.5 390,500 390,652 0,652 0,500"></polygon></clipPath>
<clipPath id="lg-pintu"><polygon points="320,212 382,203 382,489 320,403"></polygon></clipPath>
<clipPath id="lg-loket"><polygon points="12.6,175.3 60.0,189.5 60.0,305.6 12.6,332.2"></polygon></clipPath>
</defs>
<rect x="0" y="0" width="390" height="652" fill="url(#lg-langit)"></rect>
<circle cx="268" cy="150" r="30" fill="#FFE6A8" opacity="0.45"></circle><circle cx="268" cy="150" r="13" fill="#FFE6A8"></circle>
<g class="rm-awan rm-anim"><ellipse cx="150" cy="128" rx="22" ry="8" fill="#FFFFFF"></ellipse><ellipse cx="166" cy="122" rx="14" ry="8.5" fill="#FFFFFF"></ellipse><ellipse cx="226" cy="196" rx="17" ry="6.5" fill="#FFFFFF" opacity="0.9"></ellipse><ellipse cx="238" cy="191" rx="10" ry="6.5" fill="#FFFFFF" opacity="0.9"></ellipse></g>
<g class="gg-awan2 rm-anim"><ellipse cx="300" cy="230" rx="15" ry="5.5" fill="#FFFFFF" opacity="0.8"></ellipse><ellipse cx="310" cy="226" rx="9" ry="5.5" fill="#FFFFFF" opacity="0.8"></ellipse></g>
<path d="M40 276 Q100 226 158 252 Q200 230 244 248 Q296 220 350 266 V310 H40 Z" fill="#B5DC96"></path>
<path d="M60 284 Q120 252 172 270 Q214 254 256 268 Q300 250 340 280 V310 H60 Z" fill="#9ED39A"></path>
<polygon points="152.6,199.3 197.5,199.3 197.5,287.5 152.6,287.5" fill="#F8E2C4"></polygon>
<polygon points="149.3,199.3 175.1,183.5 200.8,199.3" fill="#D9785A"></polygon>
<polygon points="162.6,212.6 174.2,212.6 174.2,225.8 162.6,225.8" fill="#BFE7F7"></polygon>
<polygon points="184.2,221.7 193.3,221.7 193.3,287.5 184.2,287.5" fill="#C99466"></polygon>
<polygon points="197.5,205.9 237.4,205.9 237.4,287.5 197.5,287.5" fill="#CFE8D6"></polygon>
<polygon points="195.0,202.6 239.9,202.6 239.9,205.9 195.0,205.9" fill="#C96A4E"></polygon>
<polygon points="207.5,214.2 220.8,214.2 220.8,226.7 207.5,226.7" fill="#FFFBF3"></polygon>
<polygon points="209.1,215.9 219.1,215.9 219.1,225.0 209.1,225.0" fill="#BFE7F7"></polygon>
<polygon points="153.5,287.5 236.5,287.5 390,500 390,652 0,652 0,500" fill="url(#lg-tanah)"></polygon>
<g clip-path="url(#lg-tanahc)">
<line x1="195" y1="230" x2="-600" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-520" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-440" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-360" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-280" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-200" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-120" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="-40" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="40" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="120" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="200" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="280" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="360" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="440" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="520" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="600" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="680" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="760" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="840" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="195" y1="230" x2="920" y2="652" stroke="rgba(176,122,79,0.16)" stroke-width="1.2"></line>
<line x1="0" y1="603.8" x2="390" y2="603.8" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="552.3" x2="390" y2="552.3" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="509.0" x2="390" y2="509.0" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="471.2" x2="390" y2="471.2" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="437.7" x2="390" y2="437.7" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="408.0" x2="390" y2="408.0" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="382.6" x2="390" y2="382.6" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="358.9" x2="390" y2="358.9" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="336.8" x2="390" y2="336.8" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="316.9" x2="390" y2="316.9" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
<line x1="0" y1="299.2" x2="390" y2="299.2" stroke="rgba(176,122,79,0.15)" stroke-width="1.1"></line>
</g>
<polygon points="-75.0,603.8 -53.4,603.8 156.8,287.5 153.5,287.5" fill="#D9BC8C" opacity="0.7"></polygon>
<polygon points="443.4,603.8 465.0,603.8 236.5,287.5 233.2,287.5" fill="#D9BC8C" opacity="0.7"></polygon>
<polygon points="259.3,183.7 236.5,200.1 236.5,287.5 259.3,319.0" fill="#F8E2C4"></polygon>
<polygon points="259.3,311.3 236.5,282.5 236.5,287.5 259.3,319.0" fill="#000000" opacity="0.06"></polygon>
<polygon points="259.3,183.7 236.5,200.1 229.9,196.4 249.0,177.9" fill="#C96A4E"></polygon>
<polygon points="259.3,183.7 236.5,200.1 236.5,202.2 259.3,186.9" fill="#6B4122" opacity="0.12"></polygon>
<polygon points="253.7,206.5 245.9,209.6 245.9,240.2 253.7,241.7" fill="#FFFBF3"></polygon>
<polygon points="252.9,209.7 246.5,212.0 246.5,237.7 252.9,238.7" fill="#BFE7F7"></polygon>
<polygon points="243.2,225.2 239.3,225.6 239.3,291.3 243.2,296.8" fill="#B07A4F"></polygon>
<polygon points="133.6,184.6 153.5,199.3 153.5,287.5 133.6,315.0" fill="#CFE8D6"></polygon>
<polygon points="133.6,307.6 153.5,282.5 153.5,287.5 133.6,315.0" fill="#000000" opacity="0.06"></polygon>
<polygon points="133.6,184.6 153.5,199.3 160.1,195.5 143.5,179.1" fill="#D9785A"></polygon>
<polygon points="133.6,184.6 153.5,199.3 153.5,201.3 133.6,187.7" fill="#6B4122" opacity="0.12"></polygon>
<polygon points="138.8,206.4 146.8,209.8 146.8,238.7 138.8,240.1" fill="#FFFBF3"></polygon>
<polygon points="139.4,209.4 146.3,212.0 146.3,236.3 139.4,237.2" fill="#BFE7F7"></polygon>
<polygon points="288.8,138.1 259.3,167.0 259.3,319.0 288.8,359.8" fill="#F7D3B8"></polygon>
<polygon points="288.8,348.6 259.3,311.3 259.3,319.0 288.8,359.8" fill="#000000" opacity="0.06"></polygon>
<polygon points="288.8,138.1 259.3,167.0 249.0,161.2 273.8,129.7" fill="#D9785A"></polygon>
<polygon points="288.8,138.1 259.3,167.0 259.3,170.2 288.8,142.8" fill="#6B4122" opacity="0.12"></polygon>
<polygon points="282.1,182.1 268.0,189.9 268.0,240.9 282.1,243.1" fill="#FFFBF3"></polygon>
<polygon points="280.4,187.3 269.2,192.9 269.2,237.4 280.4,238.5" fill="#BFE7F7"></polygon>
<polygon points="265.1,216.0 260.5,216.9 260.5,320.7 265.1,327.1" fill="#B07A4F"></polygon>
<polygon points="105.0,147.2 133.6,173.5 133.6,315.0 105.0,354.6" fill="#FCE6C8"></polygon>
<polygon points="105.0,343.8 133.6,307.6 133.6,315.0 105.0,354.6" fill="#000000" opacity="0.06"></polygon>
<polygon points="105.0,147.2 133.6,173.5 143.5,168.0 119.4,139.1" fill="#C96A4E"></polygon>
<polygon points="105.0,147.2 133.6,173.5 133.6,176.6 105.0,151.7" fill="#6B4122" opacity="0.12"></polygon>
<polygon points="113.2,189.1 125.8,195.4 125.8,238.3 113.2,239.8" fill="#FFFBF3"></polygon>
<polygon points="114.6,193.8 124.7,198.4 124.7,234.9 114.6,235.6" fill="#BFE7F7"></polygon>
<polygon points="127.5,217.8 132.5,218.8 132.5,316.5 127.5,323.5" fill="#B07A4F"></polygon>
<polygon points="77.6,340.9 105.0,315.0 105.0,354.6 77.6,392.5" fill="#F6DDB4"></polygon>
<line x1="79.1" y1="339.5" x2="79.1" y2="390.4" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="82.7" y1="336.0" x2="82.7" y2="385.4" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="86.1" y1="332.8" x2="86.1" y2="380.7" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="89.3" y1="329.8" x2="89.3" y2="376.3" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="92.3" y1="327.0" x2="92.3" y2="372.1" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="95.2" y1="324.3" x2="95.2" y2="368.2" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="97.9" y1="321.7" x2="97.9" y2="364.5" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="100.4" y1="319.3" x2="100.4" y2="360.9" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="102.8" y1="317.0" x2="102.8" y2="357.6" stroke="#D9A066" stroke-width="1.6"></line>
<line x1="77.6" y1="357.3" x2="105.0" y2="327.6" stroke="#D9A066" stroke-width="1.4"></line>
<rect x="267.0" y="86.8" width="3.2" height="256.5" rx="1.4" fill="#9C8774"></rect>
<rect x="259.6" y="92.8" width="18" height="2.4" rx="1" fill="#8A7562"></rect>
<path d="M260.6 93.8 Q194.3 172.8 120.0 158.8" stroke="#6B4F3A" stroke-width="1" fill="none" opacity="0.7"></path>
<path d="M276.6 93.8 Q169.3 133.8 -10 60" stroke="#6B4F3A" stroke-width="1.1" fill="none" opacity="0.7"></path>
<path d="M260.6 95.8 Q207.7 105.8 146.8 181.8" stroke="#6B4F3A" stroke-width="0.9" fill="none" opacity="0.6"></path>
<path d="M276.6 95.8 Q328.6 143.8 400 113.8" stroke="#6B4F3A" stroke-width="1.1" fill="none" opacity="0.7"></path>
<path d="M81.8 372.7 C82.8 330 80.8 290 74.8 250 L80.8 248 C85.8 280 88.8 300 89.8 300 C94.8 280 104.8 262 116.8 252 L119.8 256 C106.8 270 94.8 300 91.8 372.7 Z" fill="#8E5A30"></path>
<circle cx="40" cy="190" r="46" fill="#67A85B"></circle>
<circle cx="105" cy="168" r="52" fill="#67A85B"></circle>
<circle cx="168" cy="200" r="40" fill="#67A85B"></circle>
<circle cx="70" cy="150" r="40" fill="#7FBF6E"></circle>
<circle cx="130" cy="140" r="42" fill="#7FBF6E"></circle>
<circle cx="185" cy="170" r="30" fill="#7FBF6E"></circle>
<circle cx="30" cy="230" r="34" fill="#7FBF6E"></circle>
<circle cx="100" cy="212" r="40" fill="#7FBF6E"></circle>
<circle cx="150" cy="232" r="30" fill="#7FBF6E"></circle>
<g class="rm-daun rm-anim"><circle cx="82" cy="196" r="22" fill="#9ED39A"></circle><circle cx="150" cy="186" r="18" fill="#9ED39A"></circle></g>
<g class="gg-daun2 rm-anim"><circle cx="48" cy="168" r="16" fill="#9ED39A"></circle><circle cx="118" cy="150" r="14" fill="#9ED39A"></circle><circle cx="176" cy="218" r="12" fill="#9ED39A"></circle></g>
<path d="M96 228 V233" stroke="#4E9A4A" stroke-width="1.2"></path><ellipse cx="96" cy="236" rx="3.6" ry="5" fill="#F2B33D"></ellipse><ellipse cx="95" cy="234.4" rx="1.2" ry="1.8" fill="#FFE39A"></ellipse>
<path d="M132 242 V247" stroke="#4E9A4A" stroke-width="1.2"></path><ellipse cx="132" cy="250" rx="3.6" ry="5" fill="#F2B33D"></ellipse><ellipse cx="131" cy="248.4" rx="1.2" ry="1.8" fill="#FFE39A"></ellipse>
<path d="M160 236 V241" stroke="#4E9A4A" stroke-width="1.2"></path><ellipse cx="160" cy="244" rx="3.6" ry="5" fill="#F2B33D"></ellipse><ellipse cx="159" cy="242.4" rx="1.2" ry="1.8" fill="#FFE39A"></ellipse>
<path d="M116 220 V225" stroke="#4E9A4A" stroke-width="1.2"></path><ellipse cx="116" cy="228" rx="3.6" ry="5" fill="#F2B33D"></ellipse><ellipse cx="115" cy="226.4" rx="1.2" ry="1.8" fill="#FFE39A"></ellipse>
<path d="M70 236 V241" stroke="#4E9A4A" stroke-width="1.2"></path><ellipse cx="70" cy="244" rx="3.6" ry="5" fill="#F2B33D"></ellipse><ellipse cx="69" cy="242.4" rx="1.2" ry="1.8" fill="#FFE39A"></ellipse>
<polygon points="420.0,-6.2 288.8,131.6 288.8,359.8 420.0,541.5" fill="url(#lg-plester)"></polygon>
<polygon points="420.0,510.0 288.8,346.7 288.8,359.8 420.0,541.5" fill="#EBC9A0"></polygon>
<polygon points="290.7,129.5 288.8,131.6 288.8,359.8 290.7,362.6" fill="#E9C9A0"></polygon>
<polygon points="310.9,165.1 292.8,175.2 292.8,253.5 310.9,257.8" fill="#FFFBF3"></polygon>
<polygon points="308.9,173.0 294.3,180.4 294.3,247.9 308.9,250.5" fill="#FCE6C8"></polygon>
<polygon points="308.9,173.0 294.3,180.4 294.3,247.9 308.9,250.5" fill="#FFE39A" opacity="0.55"></polygon>
<polygon points="308.9,173.0 304.3,175.3 304.3,249.7 308.9,250.5" fill="#F4B48C"></polygon>
<polygon points="298.1,178.5 294.3,180.4 294.3,247.9 298.1,248.5" fill="#F4B48C"></polygon>
<polygon points="311.9,255.7 292.1,251.4 292.1,257.2 311.9,262.7" fill="#B07A4F"></polygon>
<polygon points="420.0,-6.2 288.8,131.6 270.0,123.1 375.0,-26.5" fill="#B07A4F"></polygon>
<path d="M375.0 -38.5 L358.6 -15.2 L358.6 -3.2 Q366.4 5.9 375.0 -26.5 Z" fill="#D9785A"></path>
<path d="M358.6 -15.2 L345.0 4.3 L345.0 16.3 Q351.5 25.6 358.6 -3.2 Z" fill="#CF6E52"></path>
<path d="M345.0 4.3 L333.5 20.7 L333.5 32.7 Q339.0 42.2 345.0 16.3 Z" fill="#D9785A"></path>
<path d="M333.5 20.7 L323.6 34.8 L323.6 46.8 Q328.3 56.3 333.5 32.7 Z" fill="#CF6E52"></path>
<path d="M323.6 34.8 L315.0 47.0 L315.0 59.0 Q319.1 68.5 323.6 46.8 Z" fill="#D9785A"></path>
<path d="M315.0 47.0 L307.5 57.7 L307.5 69.7 Q311.1 79.1 315.0 59.0 Z" fill="#CF6E52"></path>
<path d="M307.5 57.7 L300.9 67.1 L300.9 79.1 Q304.1 88.5 307.5 69.7 Z" fill="#D9785A"></path>
<path d="M300.9 67.1 L295.0 75.5 L295.0 87.5 Q297.9 96.7 300.9 79.1 Z" fill="#CF6E52"></path>
<path d="M295.0 75.5 L289.7 83.0 L289.7 95.0 Q292.3 104.1 295.0 87.5 Z" fill="#D9785A"></path>
<path d="M289.7 83.0 L285.0 89.8 L285.0 101.8 Q287.3 110.7 289.7 95.0 Z" fill="#CF6E52"></path>
<path d="M285.0 89.8 L280.7 95.9 L280.7 107.9 Q282.8 116.7 285.0 101.8 Z" fill="#D9785A"></path>
<path d="M280.7 95.9 L276.8 101.4 L276.8 113.4 Q278.7 122.1 280.7 107.9 Z" fill="#CF6E52"></path>
<path d="M276.8 101.4 L273.3 106.5 L273.3 118.5 Q275.0 127.0 276.8 113.4 Z" fill="#D9785A"></path>
<path d="M273.3 106.5 L270.0 111.1 L270.0 123.1 Q271.6 131.5 273.3 118.5 Z" fill="#CF6E52"></path>
<g clip-path="url(#lg-pintu)">
<rect x="316" y="180" width="80" height="330" fill="url(#lg-hangat)"></rect>
<rect x="350" y="246" width="22" height="18" rx="2" fill="#FFFBF3"></rect><rect x="353" y="249" width="16" height="12" rx="1" fill="#BFE7F7"></rect>
<polygon points="316,392 396,380 396,510 316,510" fill="#E3BC86"></polygon>
<line x1="316" y1="402" x2="396" y2="396" stroke="rgba(176,122,79,0.3)" stroke-width="1.4"></line><line x1="316" y1="420" x2="396" y2="420" stroke="rgba(176,122,79,0.3)" stroke-width="1.4"></line><line x1="316" y1="446" x2="396" y2="452" stroke="rgba(176,122,79,0.3)" stroke-width="1.4"></line>
<rect x="316" y="383" width="80" height="9" fill="#B07A4F"></rect>
<polygon points="320,212 329,210.7 329,415.5 320,403" fill="#EFCB9C"></polygon>
</g>
<polygon points="313,213.6 320,212.5 320,394 313,385" fill="#C99466" stroke="#B07A4F" stroke-width="1.2" stroke-linejoin="round"></polygon>
<polygon points="313,205.5 390,189.6 390,202 313,213.6" fill="#C99466" stroke="#B07A4F" stroke-width="1.2" stroke-linejoin="round"></polygon>
<polygon points="320,403 382,489 382,496 320,409" fill="#C99466"></polygon>
<line x1="320" y1="403" x2="382" y2="489" stroke="#E7BE8E" stroke-width="1.5"></line>
<g><rect x="329.0" y="149.8" width="2" height="8" fill="#8E5A30"></rect><path d="M324.0 157.8 H336.0 L334.0 168.8 H326.0 Z" fill="#FFE39A" stroke="#B07A4F" stroke-width="1.2" stroke-linejoin="round"></path><rect x="323.0" y="155.8" width="14" height="3" rx="1.5" fill="#8E5A30"></rect></g>
<g transform="translate(363.8 159.1)"><path d="M-12 -9 L10 -12 L10 9 L-12 10 Z" fill="#FFFBF3" stroke="#B07A4F" stroke-width="1.6" stroke-linejoin="round"></path><ellipse cx="-0.6" cy="2.6" rx="4.2" ry="3.4" fill="#F29A3A"></ellipse><circle cx="-5.8" cy="-2.2" r="1.8" fill="#F29A3A"></circle><circle cx="-2.4" cy="-5" r="1.8" fill="#F29A3A"></circle><circle cx="1.6" cy="-5.2" r="1.8" fill="#F29A3A"></circle><circle cx="4.8" cy="-2.6" r="1.8" fill="#F29A3A"></circle></g>
<polygon points="323.1,469.6 362.9,469.6 324.7,415.1 293.9,415.1" fill="#C96A4E" stroke="#A9533B" stroke-width="1" stroke-linejoin="round"></polygon>
<polygon points="324.9,463.7 353.6,463.7 323.2,418.8 300.0,418.8" fill="none" stroke="#FCE6C8" stroke-width="1.6" stroke-linejoin="round" opacity="0.85"></polygon>
<line x1="318.0" y1="451.2" x2="345.2" y2="451.2" stroke="#E07A5F" stroke-width="2"></line>
<line x1="311.1" y1="438.9" x2="336.8" y2="438.9" stroke="#E07A5F" stroke-width="2"></line>
<line x1="305.0" y1="427.8" x2="329.3" y2="427.8" stroke="#E07A5F" stroke-width="2"></line>
<g><path d="M281.2 367.2 H299.2 L296.7 383.2 H283.7 Z" fill="#C8673F"></path><rect x="279.7" y="364.2" width="21" height="5" rx="2" fill="#DB7B4E"></rect><g class="rm-daun rm-anim"><ellipse cx="285.2" cy="355.2" rx="4.4" ry="11" fill="#7FBF6E" transform="rotate(-26 285.2 355.2)"></ellipse><ellipse cx="295.2" cy="354.2" rx="4.4" ry="11" fill="#67A85B" transform="rotate(24 295.2 354.2)"></ellipse><ellipse cx="290.2" cy="351.2" rx="4.4" ry="13" fill="#9ED39A"></ellipse></g></g>
<polygon points="-30.0,5.0 78.0,113.0 78.0,392.0 -30.0,541.5" fill="url(#lg-kayu)"></polygon>
<line x1="-30.0" y1="41.0" x2="78.0" y2="131.7" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="79.2" x2="78.0" y2="151.6" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="117.5" x2="78.0" y2="171.5" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="155.8" x2="78.0" y2="191.4" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="194.0" x2="78.0" y2="211.3" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="232.3" x2="78.0" y2="231.2" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="270.5" x2="78.0" y2="251.1" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="308.8" x2="78.0" y2="271.0" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="347.0" x2="78.0" y2="290.8" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="385.2" x2="78.0" y2="310.7" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="423.5" x2="78.0" y2="330.6" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="461.8" x2="78.0" y2="350.5" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="500.0" x2="78.0" y2="370.4" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<line x1="-30.0" y1="538.2" x2="78.0" y2="390.3" stroke="#A9744A" stroke-width="1.1" opacity="0.45"></line>
<polygon points="74.9,109.9 78.0,113.0 78.0,392.0 74.9,396.3" fill="#A9744A"></polygon>
<polygon points="-30.0,519.0 78.0,380.3 78.0,392.0 -30.0,541.5" fill="#9C6A42" opacity="0.5"></polygon>
<polygon points="-30.0,5.0 78.0,113.0 89.7,104.8 -7.5,-10.8" fill="#8E5A30"></polygon>
<polygon points="12.6,175.3 60.0,189.5 60.0,305.6 12.6,332.2" fill="#6E4626"></polygon>
<g clip-path="url(#lg-loket)">
<line x1="12.6" y1="222.7" x2="60.0" y2="224.6" stroke="#A9744A" stroke-width="2.4"></line>
<rect x="15.7" y="203.7" width="7.9" height="19.3" rx="1.2" fill="#F59A33"></rect>
<rect x="24.6" y="200.0" width="7.5" height="23.3" rx="1.2" fill="#2BB5A0"></rect>
<rect x="32.6" y="206.2" width="7.1" height="17.5" rx="1.2" fill="#F07F9A"></rect>
<rect x="40.8" y="202.8" width="6.8" height="21.1" rx="1.2" fill="#FFC83D"></rect>
<rect x="47.4" y="208.3" width="6.5" height="15.9" rx="1.2" fill="#7FC8E8"></rect>
<rect x="52.7" y="204.9" width="6.3" height="19.5" rx="1.2" fill="#F59A33"></rect>
<line x1="12.6" y1="277.4" x2="60.0" y2="265.1" stroke="#A9744A" stroke-width="2.4"></line>
<rect x="15.7" y="256.3" width="7.9" height="19.3" rx="1.2" fill="#F59A33"></rect>
<rect x="24.6" y="250.0" width="7.5" height="23.3" rx="1.2" fill="#2BB5A0"></rect>
<rect x="32.6" y="253.8" width="7.1" height="17.5" rx="1.2" fill="#F07F9A"></rect>
<rect x="40.8" y="248.1" width="6.8" height="21.1" rx="1.2" fill="#FFC83D"></rect>
<rect x="47.4" y="251.7" width="6.5" height="15.9" rx="1.2" fill="#7FC8E8"></rect>
<rect x="52.7" y="246.7" width="6.3" height="19.5" rx="1.2" fill="#F59A33"></rect>
</g>
<polygon points="12.6,175.3 60.0,189.5 60.0,305.6 12.6,332.2" fill="none" stroke="#8E5A30" stroke-width="2.2" stroke-linejoin="round"></polygon>
<polygon points="7.5,335.0 62.6,304.1 81.2,304.1 33.8,335.0" fill="#E2AE73"></polygon>
<polygon points="33.8,335.0 81.2,304.1 81.2,313.4 33.8,348.1" fill="#B07A4F"></polygon>
<polygon points="7.5,335.0 33.8,335.0 33.8,348.1 7.5,348.1" fill="#9C6A42"></polygon>
<g><rect x="29.6" y="303.7" width="16.9" height="20.8" rx="3.7" fill="#EAF6FB" opacity="0.92" stroke="#A9C9D8" stroke-width="1"></rect><circle cx="35.5" cy="313.1" r="3.4" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="40.8" cy="316.9" r="3.2" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="37.2" cy="319.9" r="2.9" fill="#F6DDB4" stroke="#E2C08F" stroke-width="0.8"></circle><rect x="28.6" y="299.2" width="18.9" height="5.1" rx="1.4" fill="#D9574A"></rect><rect x="32.0" y="306.3" width="2.0" height="12.7" rx="1" fill="#FFFFFF" opacity="0.7"></rect></g>
<g><rect x="46.3" y="296.3" width="15.2" height="18.7" rx="3.3" fill="#EAF6FB" opacity="0.92" stroke="#A9C9D8" stroke-width="1"></rect><circle cx="51.7" cy="304.7" r="3.0" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="56.4" cy="308.1" r="2.9" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="53.2" cy="310.8" r="2.6" fill="#F6DDB4" stroke="#E2C08F" stroke-width="0.8"></circle><rect x="45.4" y="292.2" width="17.0" height="4.6" rx="1.2" fill="#D9574A"></rect><rect x="48.5" y="298.6" width="1.8" height="11.4" rx="1" fill="#FFFFFF" opacity="0.7"></rect></g>
<g><rect x="59.3" y="290.5" width="13.8" height="17.0" rx="3.0" fill="#EAF6FB" opacity="0.92" stroke="#A9C9D8" stroke-width="1"></rect><circle cx="64.2" cy="298.2" r="2.8" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="68.4" cy="301.3" r="2.6" fill="#FCE6C8" stroke="#E2C08F" stroke-width="0.8"></circle><circle cx="65.5" cy="303.8" r="2.4" fill="#F6DDB4" stroke="#E2C08F" stroke-width="0.8"></circle><rect x="58.5" y="286.8" width="15.5" height="4.2" rx="1.1" fill="#D9574A"></rect><rect x="61.2" y="292.6" width="1.7" height="10.4" rx="1" fill="#FFFFFF" opacity="0.7"></rect></g>
<polygon points="63.9,195.9 76.1,199.1 76.1,394.7 63.9,411.5" fill="#8E5A30"></polygon>
<polygon points="65.8,204.2 74.5,205.9 74.5,396.9 65.8,408.9" fill="#6E4626"></polygon>
<polygon points="65.8,204.2 69.4,204.9 69.4,403.9 65.8,408.9" fill="#A9744A"></polygon>
<polygon points="60.0,402.1 84.3,402.1 84.3,416.9 60.0,416.9" fill="#D9BC90"></polygon>
<polygon points="84.3,402.1 99.1,379.1 99.1,392.0 84.3,416.9" fill="#CDAE82"></polygon>
<polygon points="60.0,402.1 84.3,402.1 99.1,379.1 78.0,379.1" fill="#EAD5B0"></polygon>
<polygon points="62.0,384.9 74.0,384.9 74.0,414.2 62.0,414.2" fill="#D9BC90"></polygon>
<polygon points="74.0,384.9 86.8,368.5 86.8,394.7 74.0,414.2" fill="#CDAE82"></polygon>
<polygon points="62.0,384.9 74.0,384.9 86.8,368.5 76.1,368.5" fill="#F0DDBB"></polygon>
<polygon points="-30.0,95.0 78.0,159.8 78.0,176.2 -30.0,126.5" fill="#6B4122" opacity="0.14"></polygon>
<g><ellipse cx="51.0" cy="477.2" rx="16.2" ry="5.2" fill="#4FA3C9"></ellipse><ellipse cx="51.0" cy="475.8" rx="16.2" ry="4.9" fill="#7FC8E8"></ellipse><ellipse cx="51.0" cy="475.6" rx="12.3" ry="3.2" fill="#BFE7F7"></ellipse><ellipse cx="47.0" cy="474.8" rx="3.6" ry="1" fill="#FFFFFF" opacity="0.85"></ellipse></g>
<path d="M27.8 460.8 Q28.9 451.9 25.6 447.4 Q32.2 453.0 33.3 445.2 Q35.6 453.0 41.1 448.5 Q37.8 454.1 38.9 460.8 Z" fill="#7FBF6E"></path>
<path d="M77.2 392.5 Q78.0 386.3 75.7 383.2 Q80.3 387.1 81.1 381.6 Q82.7 387.1 86.6 383.9 Q84.3 387.8 85.0 392.5 Z" fill="#7FBF6E"></path>
<path d="M292.3 373.8 Q293.0 368.2 290.9 365.5 Q295.0 368.9 295.7 364.1 Q297.1 368.9 300.6 366.2 Q298.5 369.6 299.2 373.8 Z" fill="#7FBF6E"></path>
<path d="M107.6 350.6 Q108.2 346.0 106.5 343.6 Q109.9 346.5 110.5 342.5 Q111.7 346.5 114.6 344.2 Q112.8 347.1 113.4 350.6 Z" fill="#7FBF6E"></path>
<path d="M375.6 497.0 Q376.9 486.7 373.1 481.6 Q380.8 488.0 382.1 479.0 Q384.6 488.0 391.1 482.9 Q387.2 489.3 388.5 497.0 Z" fill="#7FBF6E"></path>
<polygon points="-46.1,85.4 -28.7,95.8 60.8,136.0 50.4,128.8" fill="#D9574A"></polygon><polygon points="-28.7,95.8 -13.7,104.8 69.8,142.4 60.8,136.0" fill="#FCE6C8"></polygon><polygon points="-13.7,104.8 -0.5,112.7 77.7,147.9 69.8,142.4" fill="#D9574A"></polygon><polygon points="-0.5,112.7 11.1,119.6 84.6,152.7 77.7,147.9" fill="#FCE6C8"></polygon><polygon points="11.1,119.6 21.4,125.8 90.8,157.1 84.6,152.7" fill="#D9574A"></polygon><polygon points="21.4,125.8 30.6,131.3 96.3,160.9 90.8,157.1" fill="#FCE6C8"></polygon><polygon points="30.6,131.3 38.8,136.3 101.3,164.4 96.3,160.9" fill="#D9574A"></polygon><polygon points="38.8,136.3 46.3,140.8 105.8,167.5 101.3,164.4" fill="#FCE6C8"></polygon><polygon points="46.3,140.8 53.1,144.9 109.9,170.4 105.8,167.5" fill="#D9574A"></polygon><polygon points="53.1,144.9 59.3,148.6 113.6,173.0 109.9,170.4" fill="#FCE6C8"></polygon><polygon points="59.3,148.6 65.0,152.0 117.0,175.4 113.6,173.0" fill="#D9574A"></polygon><polygon points="65.0,152.0 70.2,155.1 120.1,177.6 117.0,175.4" fill="#FCE6C8"></polygon><polygon points="70.2,155.1 75.0,158.0 123.0,179.6 120.1,177.6" fill="#D9574A"></polygon><polygon points="75.0,158.0 79.5,160.7 125.7,181.5 123.0,179.6" fill="#FCE6C8"></polygon>
<polygon points="-46.1,80.5 79.5,158.4 79.5,163.0 -46.1,90.2" fill="#B8443A"></polygon>
<g class="gg-kibar rm-anim"><path d="M50.4 128.8 L60.8 136.0 L60.8 156.2 Q55.8 162.7 50.4 150.4 Z" fill="#D9574A"></path><path d="M60.8 136.0 L69.8 142.4 L69.8 161.1 Q65.4 167.4 60.8 156.2 Z" fill="#FCE6C8"></path><path d="M69.8 142.4 L77.7 147.9 L77.7 165.5 Q73.9 171.5 69.8 161.1 Z" fill="#D9574A"></path><path d="M77.7 147.9 L84.6 152.7 L84.6 169.3 Q81.3 175.0 77.7 165.5 Z" fill="#FCE6C8"></path><path d="M84.6 152.7 L90.8 157.1 L90.8 172.7 Q87.8 178.2 84.6 169.3 Z" fill="#D9574A"></path><path d="M90.8 157.1 L96.3 160.9 L96.3 175.7 Q93.6 181.0 90.8 172.7 Z" fill="#FCE6C8"></path><path d="M96.3 160.9 L101.3 164.4 L101.3 178.5 Q98.9 183.5 96.3 175.7 Z" fill="#D9574A"></path><path d="M101.3 164.4 L105.8 167.5 L105.8 180.9 Q103.6 185.8 101.3 178.5 Z" fill="#FCE6C8"></path><path d="M105.8 167.5 L109.9 170.4 L109.9 183.2 Q107.9 187.9 105.8 180.9 Z" fill="#D9574A"></path><path d="M109.9 170.4 L113.6 173.0 L113.6 185.2 Q111.8 189.8 109.9 183.2 Z" fill="#FCE6C8"></path><path d="M113.6 173.0 L117.0 175.4 L117.0 187.1 Q115.3 191.5 113.6 185.2 Z" fill="#D9574A"></path><path d="M117.0 175.4 L120.1 177.6 L120.1 188.8 Q118.6 193.1 117.0 187.1 Z" fill="#FCE6C8"></path><path d="M120.1 177.6 L123.0 179.6 L123.0 190.4 Q121.6 194.5 120.1 188.8 Z" fill="#D9574A"></path><path d="M123.0 179.6 L125.7 181.5 L125.7 191.9 Q124.4 195.9 123.0 190.4 Z" fill="#FCE6C8"></path><path d="M50.4 128.8 125.7 181.5" stroke="#B8443A" stroke-width="1.2"></path></g>
<g><path d="M99.4 179.2 V192.8 M132.0 179.2 V192.8" stroke="#6B4F3A" stroke-width="1"></path><rect x="93.4" y="192.8" width="44.6" height="21.1" rx="3" fill="#FFFBF3" stroke="#B07A4F" stroke-width="1.6"></rect><g transform="translate(105.5 204.6)"><path d="M-6 -4 H4 V3 A3 3 0 0 1 1 6 H-3 A3 3 0 0 1 -6 3 Z" fill="#2F86B8"></path><path d="M4 -2 A3 3 0 0 1 4 4" stroke="#2F86B8" stroke-width="1.6" fill="none"></path><path d="M-3 -6.5 Q-1.6 -8 -3 -9.6 M0.4 -6.5 Q1.8 -8 0.4 -9.6" stroke="#B07A4F" stroke-width="1" fill="none" stroke-linecap="round"></path></g><g transform="translate(125.5 203.4)"><path d="M-5.5 -6.5 L5.5 -6.5 L4.6 6.5 L-4.6 6.5 Z" fill="#F59A33"></path><path d="M-5.5 -6.5 L-4 -8 L-2.5 -6.5 L-1 -8 L0.5 -6.5 L2 -8 L3.5 -6.5 L5 -8 L5.5 -6.5 Z M-4.6 6.5 L-3.1 8 L-1.6 6.5 L-0.1 8 L1.4 6.5 L2.9 8 L4.4 6.5 Z" fill="#D97B2E"></path><ellipse cx="0" cy="0" rx="2.6" ry="3" fill="#FFE39A"></ellipse></g></g>
<g class="gg-ayun rm-anim" style="transform-origin: 61.8px 147.2px; animation-delay: -0.0s"><line x1="61.8" y1="147.2" x2="61.8" y2="251.6" stroke="#6B4F3A" stroke-width="0.9"></line><rect x="56.4" y="159.7" width="10.8" height="15.3" rx="1.2" fill="#F07F9A"></rect><rect x="56.4" y="159.7" width="10.8" height="2.4" fill="#FFFFFF" opacity="0.45"></rect><circle cx="61.8" cy="168.6" r="1.9" fill="#FFFBF3" opacity="0.8"></circle><rect x="56.4" y="183.7" width="10.8" height="15.3" rx="1.2" fill="#FFC83D"></rect><rect x="56.4" y="183.7" width="10.8" height="2.4" fill="#FFFFFF" opacity="0.45"></rect><circle cx="61.8" cy="192.6" r="1.9" fill="#FFFBF3" opacity="0.8"></circle><rect x="56.4" y="207.8" width="10.8" height="15.3" rx="1.2" fill="#2BB5A0"></rect><rect x="56.4" y="207.8" width="10.8" height="2.4" fill="#FFFFFF" opacity="0.45"></rect><circle cx="61.8" cy="216.6" r="1.9" fill="#FFFBF3" opacity="0.8"></circle><rect x="56.4" y="231.8" width="10.8" height="15.3" rx="1.2" fill="#F59A33"></rect><rect x="56.4" y="231.8" width="10.8" height="2.4" fill="#FFFFFF" opacity="0.45"></rect><circle cx="61.8" cy="240.6" r="1.9" fill="#FFFBF3" opacity="0.8"></circle></g><g class="gg-ayun rm-anim" style="transform-origin: 73.2px 154.3px; animation-delay: -0.7s"><line x1="73.2" y1="154.3" x2="73.2" y2="249.8" stroke="#6B4F3A" stroke-width="0.9"></line><rect x="68.2" y="165.7" width="9.9" height="14.0" rx="1.2" fill="#FFC83D"></rect><rect x="68.2" y="165.7" width="9.9" height="2.2" fill="#FFFFFF" opacity="0.45"></rect><circle cx="73.2" cy="173.8" r="1.8" fill="#FFFBF3" opacity="0.8"></circle><rect x="68.2" y="187.7" width="9.9" height="14.0" rx="1.2" fill="#2BB5A0"></rect><rect x="68.2" y="187.7" width="9.9" height="2.2" fill="#FFFFFF" opacity="0.45"></rect><circle cx="73.2" cy="195.8" r="1.8" fill="#FFFBF3" opacity="0.8"></circle><rect x="68.2" y="209.7" width="9.9" height="14.0" rx="1.2" fill="#F59A33"></rect><rect x="68.2" y="209.7" width="9.9" height="2.2" fill="#FFFFFF" opacity="0.45"></rect><circle cx="73.2" cy="217.8" r="1.8" fill="#FFFBF3" opacity="0.8"></circle><rect x="68.2" y="231.6" width="9.9" height="14.0" rx="1.2" fill="#7FC8E8"></rect><rect x="68.2" y="231.6" width="9.9" height="2.2" fill="#FFFFFF" opacity="0.45"></rect><circle cx="73.2" cy="239.7" r="1.8" fill="#FFFBF3" opacity="0.8"></circle></g><g class="gg-ayun rm-anim" style="transform-origin: 82.8px 160.2px; animation-delay: -1.4s"><line x1="82.8" y1="160.2" x2="82.8" y2="248.2" stroke="#6B4F3A" stroke-width="0.9"></line><rect x="78.2" y="170.8" width="9.1" height="12.9" rx="1.2" fill="#2BB5A0"></rect><rect x="78.2" y="170.8" width="9.1" height="2.1" fill="#FFFFFF" opacity="0.45"></rect><circle cx="82.8" cy="178.3" r="1.6" fill="#FFFBF3" opacity="0.8"></circle><rect x="78.2" y="191.0" width="9.1" height="12.9" rx="1.2" fill="#F59A33"></rect><rect x="78.2" y="191.0" width="9.1" height="2.1" fill="#FFFFFF" opacity="0.45"></rect><circle cx="82.8" cy="198.5" r="1.6" fill="#FFFBF3" opacity="0.8"></circle><rect x="78.2" y="211.3" width="9.1" height="12.9" rx="1.2" fill="#7FC8E8"></rect><rect x="78.2" y="211.3" width="9.1" height="2.1" fill="#FFFFFF" opacity="0.45"></rect><circle cx="82.8" cy="218.7" r="1.6" fill="#FFFBF3" opacity="0.8"></circle><rect x="78.2" y="231.5" width="9.1" height="12.9" rx="1.2" fill="#B79CE0"></rect><rect x="78.2" y="231.5" width="9.1" height="2.1" fill="#FFFFFF" opacity="0.45"></rect><circle cx="82.8" cy="239.0" r="1.6" fill="#FFFBF3" opacity="0.8"></circle></g><g class="gg-ayun rm-anim" style="transform-origin: 90.9px 165.3px; animation-delay: -2.0999999999999996s"><line x1="90.9" y1="165.3" x2="90.9" y2="246.9" stroke="#6B4F3A" stroke-width="0.9"></line><rect x="86.7" y="175.1" width="8.4" height="12.0" rx="1.2" fill="#F59A33"></rect><rect x="86.7" y="175.1" width="8.4" height="1.9" fill="#FFFFFF" opacity="0.45"></rect><circle cx="90.9" cy="182.0" r="1.5" fill="#FFFBF3" opacity="0.8"></circle><rect x="86.7" y="193.9" width="8.4" height="12.0" rx="1.2" fill="#7FC8E8"></rect><rect x="86.7" y="193.9" width="8.4" height="1.9" fill="#FFFFFF" opacity="0.45"></rect><circle cx="90.9" cy="200.8" r="1.5" fill="#FFFBF3" opacity="0.8"></circle><rect x="86.7" y="212.6" width="8.4" height="12.0" rx="1.2" fill="#B79CE0"></rect><rect x="86.7" y="212.6" width="8.4" height="1.9" fill="#FFFFFF" opacity="0.45"></rect><circle cx="90.9" cy="219.6" r="1.5" fill="#FFFBF3" opacity="0.8"></circle><rect x="86.7" y="231.4" width="8.4" height="12.0" rx="1.2" fill="#F07F9A"></rect><rect x="86.7" y="231.4" width="8.4" height="1.9" fill="#FFFFFF" opacity="0.45"></rect><circle cx="90.9" cy="238.3" r="1.5" fill="#FFFBF3" opacity="0.8"></circle></g>''';

/// Cahaya gang di tanah, di bawah kucing (`CahayaGang.dc.html`, `lantai`). viewBox 0 0 390 652.
const laneFloorLightSvg =
    r'''<defs><linearGradient id="cg-tumpah" x1="1" y1="0" x2="0" y2="0.7"><stop offset="0" stop-color="#FFD98A" stop-opacity="0.9"></stop><stop offset="1" stop-color="#FFD98A" stop-opacity="0"></stop></linearGradient><radialGradient id="cg-bercak" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#FFF6D6" stop-opacity="0.55"></stop><stop offset="1" stop-color="#FFF6D6" stop-opacity="0"></stop></radialGradient></defs><polygon points="-30.0,541.5 51.0,541.5 120.2,391.8 78.1,391.8" fill="#5A3B1E" opacity="0.07"></polygon><g fill="#5A4A2A" opacity="0.12"><ellipse cx="64" cy="560" rx="46" ry="12"></ellipse><ellipse cx="118" cy="574" rx="40" ry="11"></ellipse><ellipse cx="170" cy="556" rx="30" ry="9"></ellipse><ellipse cx="92" cy="598" rx="50" ry="13"></ellipse><ellipse cx="150" cy="606" rx="34" ry="10"></ellipse><ellipse cx="36" cy="590" rx="24" ry="9"></ellipse><ellipse cx="126" cy="540" rx="26" ry="7"></ellipse><ellipse cx="198" cy="584" rx="22" ry="7"></ellipse></g><g><ellipse cx="96" cy="566" rx="10" ry="3.4" fill="url(#cg-bercak)"></ellipse><ellipse cx="142" cy="590" rx="8" ry="2.8" fill="url(#cg-bercak)"></ellipse><ellipse cx="70" cy="604" rx="9" ry="3" fill="url(#cg-bercak)"></ellipse><ellipse cx="176" cy="570" rx="7" ry="2.4" fill="url(#cg-bercak)"></ellipse></g><polygon points="81.2,476.1 230.5,476.1 234.6,440.7 106.7,440.7" fill="#3B2716" opacity="0.1"></polygon><polygon class="rm-denyut rm-anim" points="362.6,487.7 382,489 334,606 266,568" fill="url(#cg-tumpah)"></polygon><ellipse cx="290" cy="384" rx="13" ry="3" fill="#3B2716" opacity="0.14"></ellipse>''';

/// Cahaya gang di udara dan kupu-kupu (`{{kupu}}`), di atas kucing (`CahayaGang.dc.html`, `udara`). viewBox 0 0 390 652.
const laneAirLightSvg =
    r'''<defs><radialGradient id="cg-lampu" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#FFE39A" stop-opacity="0.75"></stop><stop offset="1" stop-color="#FFE39A" stop-opacity="0"></stop></radialGradient><linearGradient id="cg-berkas" x1="1" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFE9B0" stop-opacity="0.32"></stop><stop offset="1" stop-color="#FFE9B0" stop-opacity="0"></stop></linearGradient><radialGradient id="cg-vignet" cx="0.5" cy="0.56" r="0.8"><stop offset="0.64" stop-color="#6B4122" stop-opacity="0"></stop><stop offset="1" stop-color="#6B4122" stop-opacity="0.14"></stop></radialGradient><radialGradient id="cg-terik" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#FFF6D6" stop-opacity="0.35"></stop><stop offset="1" stop-color="#FFF6D6" stop-opacity="0"></stop></radialGradient></defs><circle cx="290" cy="110" r="170" fill="url(#cg-terik)"></circle><circle class="rm-denyut rm-anim" cx="330" cy="168" r="28" fill="url(#cg-lampu)"></circle><polygon class="rm-denyut rm-anim" points="364,208 382,204 300,600 252,560" fill="url(#cg-berkas)"></polygon><sc-if value="{{kupu}}" hint-placeholder-val="{{ true }}"><g class="gg-kupu rm-anim" style="animation-delay: 0s"><g transform="translate(238 430)"><g class="gg-sayap rm-anim"><ellipse cx="-4" cy="-2" rx="4.4" ry="3.4" fill="#FFC83D" transform="rotate(-20 -4 -2)"></ellipse><ellipse cx="-3.4" cy="2.6" rx="3" ry="2.4" fill="#F59A33" transform="rotate(20 -3.4 2.6)"></ellipse><ellipse cx="4" cy="-2" rx="4.4" ry="3.4" fill="#FFC83D" transform="rotate(20 4 -2)"></ellipse><ellipse cx="3.4" cy="2.6" rx="3" ry="2.4" fill="#F59A33" transform="rotate(-20 3.4 2.6)"></ellipse></g><ellipse cx="0" cy="0.4" rx="0.9" ry="3.6" fill="#3B2716"></ellipse><path d="M-0.4 -3 Q-1.6 -5.4 -2.8 -5.8 M0.4 -3 Q1.6 -5.4 2.8 -5.8" stroke="#3B2716" stroke-width="0.6" fill="none"></path></g></g><g class="gg-kupu2 rm-anim" style="animation-delay: -3s"><g transform="translate(150 300)"><g class="gg-sayap rm-anim"><ellipse cx="-4" cy="-2" rx="4.4" ry="3.4" fill="#BFE7F7" transform="rotate(-20 -4 -2)"></ellipse><ellipse cx="-3.4" cy="2.6" rx="3" ry="2.4" fill="#7FC8E8" transform="rotate(20 -3.4 2.6)"></ellipse><ellipse cx="4" cy="-2" rx="4.4" ry="3.4" fill="#BFE7F7" transform="rotate(20 4 -2)"></ellipse><ellipse cx="3.4" cy="2.6" rx="3" ry="2.4" fill="#7FC8E8" transform="rotate(-20 3.4 2.6)"></ellipse></g><ellipse cx="0" cy="0.4" rx="0.9" ry="3.6" fill="#3B2716"></ellipse><path d="M-0.4 -3 Q-1.6 -5.4 -2.8 -5.8 M0.4 -3 Q1.6 -5.4 2.8 -5.8" stroke="#3B2716" stroke-width="0.6" fill="none"></path></g></g></sc-if><rect x="0" y="0" width="390" height="652" fill="url(#cg-vignet)"></rect>''';

/// Kusen depan pintu pulang di gang, di atas kucing yang lewat (`KusenGang.dc.html`). viewBox 0 0 390 652.
const laneFrameSvg =
    r'''<polygon points="381,191.3 392,189 392,503 381,487.5" fill="#C99466" stroke="#B07A4F" stroke-width="1.4" stroke-linejoin="round"></polygon><polygon points="381,191.3 384.5,190.6 384.5,492.3 381,487.5" fill="#B98556"></polygon>''';

/// Kusen depan pintu depan ruang tengah (`KusenDepan.dc.html`). viewBox 0 0 390 652.
const livingFrontFrameSvg =
    r'''<polygon points="9,191.3 -2,189 -2,503 9,487.5" fill="#C99466" stroke="#B07A4F" stroke-width="1.4" stroke-linejoin="round"></polygon><polygon points="9,191.3 5.5,190.6 5.5,492.3 9,487.5" fill="#B98556"></polygon>''';

/// Bangku gang lapis belakang: kaki belakang dan dudukan (`Bangku.dc.html`, `belakang`). viewBox 0 0 390 652.
const benchBackSvg =
    r'''<polygon points="111.7,397.3 118.7,397.3 118.7,445.6 111.7,445.6" fill="#9C6A42"></polygon><polygon points="215.2,397.3 222.2,397.3 222.2,445.6 215.2,445.6" fill="#9C6A42"></polygon><polygon points="111.7,426.9 222.2,426.9 222.2,431.6 111.7,431.6" fill="#9C6A42"></polygon><polygon points="107.9,444.9 115.2,426.9 115.2,431.6 107.9,450.0" fill="#A9744A"></polygon><polygon points="220.9,444.9 218.7,426.9 218.7,431.6 220.9,450.0" fill="#A9744A"></polygon><polygon points="95.2,406.3 232.9,406.3 228.9,387.7 105.7,387.7" fill="#D4A170" stroke="#B07A4F" stroke-width="1" stroke-linejoin="round"></polygon><line x1="100.6" y1="399.7" x2="229.8" y2="399.7" stroke="#B07A4F" stroke-width="1.1" opacity="0.7"></line><line x1="104.1" y1="393.5" x2="228.5" y2="393.5" stroke="#B07A4F" stroke-width="1.1" opacity="0.7"></line>''';

/// Bangku gang lapis depan: tepi dudukan dan kaki depan (`Bangku.dc.html`, `depan`). viewBox 0 0 390 652.
const benchFrontSvg =
    r'''<polygon points="95.2,406.3 232.9,406.3 232.9,414.9 95.2,414.9" fill="#B07A4F"></polygon><polygon points="95.2,406.3 232.9,406.3 232.9,408.4 95.2,408.4" fill="#C99466"></polygon><polygon points="104.1,412.6 111.7,412.6 111.7,465.3 104.1,465.3" fill="#B07A4F"></polygon><polygon points="217.1,412.6 224.7,412.6 224.7,465.3 217.1,465.3" fill="#B07A4F"></polygon><polygon points="104.1,444.9 224.7,444.9 224.7,450.0 104.1,450.0" fill="#A9744A"></polygon>''';

/// Penanda "Oyen di gang" di dekat pintu depan (`PenandaGang.dc.html`). viewBox 0 0 48 52.
const laneMarkerSvg = r'''<circle cx="37" cy="48" r="2.8" fill="#FFFBF3" stroke="#C9650C" stroke-width="1.6"></circle>
    <circle cx="31" cy="41" r="4" fill="#FFFBF3" stroke="#C9650C" stroke-width="1.8"></circle>
    <circle cx="20" cy="20" r="18" fill="#FFFBF3" stroke="#C9650C" stroke-width="2"></circle>
    <ellipse cx="20" cy="24.4" rx="6.4" ry="5.4" fill="#F29A3A"></ellipse>
    <ellipse cx="12.6" cy="17.4" rx="2.6" ry="3.3" fill="#F29A3A" transform="rotate(-18 12.6 17.4)"></ellipse>
    <ellipse cx="17.4" cy="13" rx="2.6" ry="3.4" fill="#F29A3A" transform="rotate(-6 17.4 13)"></ellipse>
    <ellipse cx="22.8" cy="13" rx="2.6" ry="3.4" fill="#F29A3A" transform="rotate(6 22.8 13)"></ellipse>
    <ellipse cx="27.6" cy="17.4" rx="2.6" ry="3.3" fill="#F29A3A" transform="rotate(18 27.6 17.4)"></ellipse>''';

/// Ekor Kumis di pintu kucing ruang tengah, goyang `ekGoyang` di sekitar pangkalnya (46,2, 426,2) (`AdeganTengah.dc.html`). viewBox 0 0 390 652.
const kumisTailSvg =
    r'''<g class="ek-goyang rm-anim" style="transform-origin: 46.2px 426.2px">
<path d="M46.2 426.2 C47.7 415.2 49.2 405.2 52.2 397.2" stroke="#93A2B4" stroke-width="8.6" fill="none" stroke-linecap="round"></path>
<path d="M46.2 426.2 C47.7 415.2 49.2 405.2 52.2 397.2" stroke="#5E6E82" stroke-width="8.6" fill="none" stroke-dasharray="2.4 4" stroke-dashoffset="-2"></path>
<path d="M52.2 397.2 C53.7 392.7 57.7 390.7 62.2 392.2" stroke="#55657A" stroke-width="8.6" fill="none" stroke-linecap="round"></path>
</g>''';

/// Gelembung "!" di atas Oyen saat menyadari ekor (`AdeganTengah.dc.html`). viewBox 0 0 24 30.
const seruSvg =
    r'''<path d="M12 29 L8.6 23.6 H5 A4 4 0 0 1 1 19.6 V5 A4 4 0 0 1 5 1 H19 A4 4 0 0 1 23 5 V19.6 A4 4 0 0 1 19 23.6 H15.4 Z" fill="#FFFBF3" stroke="#C9650C" stroke-width="2" stroke-linejoin="round"></path><rect x="10" y="4.6" width="4" height="10.4" rx="2" fill="#C9650C"></rect><circle cx="12" cy="18.6" r="2.2" fill="#C9650C"></circle>''';

/// `@keyframes` lapisan gang, penanda, ekor, dan "!".
const laneKeyframesCss = r'''@keyframes rmAwan{0%{transform:translateX(-10px)}100%{transform:translateX(22px)}}
@keyframes ggAwan2{0%{transform:translateX(14px)}100%{transform:translateX(-12px)}}
@keyframes rmDaun{0%,100%{transform:rotate(-4deg)}50%{transform:rotate(4deg)}}
@keyframes ggDaun2{0%,100%{transform:translate(0,0)}50%{transform:translate(1.6px,-1px)}}
@keyframes rmDenyut{0%,100%{opacity:0.78}50%{opacity:1}}
@keyframes ggAyun{0%{transform:rotate(-4deg)}100%{transform:rotate(4deg)}}
@keyframes ggKibar{0%,100%{transform:skewX(0deg)}50%{transform:skewX(-2.2deg)}}
@keyframes ggKupu{0%{transform:translate(0,0)}20%{transform:translate(26px,-18px)}40%{transform:translate(52px,-4px)}60%{transform:translate(34px,16px)}80%{transform:translate(8px,8px)}100%{transform:translate(0,0)}}
@keyframes ggKupu2{0%{transform:translate(0,0)}25%{transform:translate(-22px,12px)}50%{transform:translate(-40px,-6px)}75%{transform:translate(-14px,-16px)}100%{transform:translate(0,0)}}
@keyframes ggSayap{0%{transform:scaleX(1)}100%{transform:scaleX(0.25)}}
@keyframes pgBob{0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}
@keyframes ekGoyang{0%{transform:rotate(-7deg)}100%{transform:rotate(9deg)}}
@keyframes atSeru{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-3px) scale(1.06)}}''';

/// Kelas animasi lapisan gang (deklarasi CSS desain).
const laneClassStyles = {
  'rm-awan': 'animation: rmAwan 16s ease-in-out infinite alternate',
  'gg-awan2': 'animation: ggAwan2 22s ease-in-out infinite alternate',
  'rm-daun': 'transform-box: fill-box; transform-origin: 50% 100%; animation: rmDaun 3.6s ease-in-out infinite',
  'gg-daun2': 'animation: ggDaun2 4.4s ease-in-out infinite',
  'rm-denyut': 'animation: rmDenyut 5s ease-in-out infinite',
  'gg-ayun': 'animation: ggAyun 2.8s ease-in-out infinite alternate',
  'gg-kibar': 'transform-box: fill-box; transform-origin: 50% 0%; animation: ggKibar 3.2s ease-in-out infinite',
  'gg-kupu': 'animation: ggKupu 9s ease-in-out infinite',
  'gg-kupu2': 'animation: ggKupu2 11s ease-in-out infinite',
  'gg-sayap': 'animation: ggSayap 0.18s ease-in-out infinite alternate',
  'pg-bob': 'animation: pgBob 2.4s ease-in-out infinite',
  'ek-goyang': 'animation: ekGoyang 0.55s ease-in-out infinite alternate',
  'at-seru':
      'animation: atSeru 0.9s ease-in-out infinite; transform-origin: 50% 100%',
};

/// Data daun pintu depan dan pintu pulang (`PintuDepan.dc.html`, `DATA`):
/// `E` = poligon daun (`f` `d` sisi dalam, `l` sisi luar; `p` titik
/// (u, v) 0–1 dari engsel dan atas; `h` lubang pintu kucing), `FL` =
/// poligon daun pintu kucing (a, b 0–1).
const doorLeafData = {
  'E': [
    {
      'f': 'd',
      'p': [
        [0.0, 0.0],
        [1.0, 0.0],
        [1.0, 1.0],
        [0.0, 1.0],
      ],
      'h': [
        [0.2, 0.65],
        [0.8, 0.65],
        [0.8, 0.96],
        [0.2, 0.96],
      ],
      'fill': '#C99466',
      'st': '#B07A4F',
      'sw': 1.2,
    },
    {
      'f': 'd',
      'p': [
        [0.0, 0.0],
        [0.055, 0.0],
        [0.055, 1.0],
        [0.0, 1.0],
      ],
      'h': null,
      'fill': '#B98556',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.945, 0.0],
        [1.0, 0.0],
        [1.0, 1.0],
        [0.945, 1.0],
      ],
      'h': null,
      'fill': '#D4A06E',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.17, 0.085],
        [0.83, 0.085],
        [0.83, 0.395],
        [0.17, 0.395],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'd',
      'p': [
        [0.225, 0.12],
        [0.775, 0.12],
        [0.775, 0.36],
        [0.225, 0.36],
      ],
      'h': null,
      'fill': '#BFE7F7',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.225, 0.27],
        [0.775, 0.27],
        [0.775, 0.36],
        [0.225, 0.36],
      ],
      'h': null,
      'fill': '#E4F5EC',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.225, 0.36],
        [0.225, 0.3],
        [0.27, 0.285],
        [0.31, 0.3],
        [0.35, 0.29],
        [0.38, 0.31],
        [0.38, 0.36],
      ],
      'h': null,
      'fill': '#9ED39A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.47, 0.12],
        [0.531, 0.12],
        [0.595, 0.175],
        [0.55, 0.165],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.55, 0.165],
        [0.595, 0.175],
        [0.5725, 0.188],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.531, 0.12],
        [0.592, 0.12],
        [0.64, 0.185],
        [0.595, 0.175],
      ],
      'h': null,
      'fill': '#FCE6C8',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.595, 0.175],
        [0.64, 0.185],
        [0.6175, 0.198],
      ],
      'h': null,
      'fill': '#FCE6C8',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.592, 0.12],
        [0.653, 0.12],
        [0.685, 0.195],
        [0.64, 0.185],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.64, 0.185],
        [0.685, 0.195],
        [0.6625, 0.208],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.653, 0.12],
        [0.714, 0.12],
        [0.73, 0.205],
        [0.685, 0.195],
      ],
      'h': null,
      'fill': '#FCE6C8',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.685, 0.195],
        [0.73, 0.205],
        [0.7075, 0.218],
      ],
      'h': null,
      'fill': '#FCE6C8',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.714, 0.12],
        [0.775, 0.12],
        [0.775, 0.215],
        [0.73, 0.205],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.73, 0.205],
        [0.775, 0.215],
        [0.7525, 0.228],
      ],
      'h': null,
      'fill': '#D9574A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.49, 0.12],
        [0.51, 0.12],
        [0.51, 0.36],
        [0.49, 0.36],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.225, 0.235],
        [0.775, 0.235],
        [0.775, 0.248],
        [0.225, 0.248],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.15, 0.39],
        [0.85, 0.39],
        [0.85, 0.41],
        [0.15, 0.41],
      ],
      'h': null,
      'fill': '#B07A4F',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.2, 0.45],
        [0.47, 0.45],
        [0.47, 0.6],
        [0.2, 0.6],
      ],
      'h': null,
      'fill': '#D9A066',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'd',
      'p': [
        [0.24, 0.47],
        [0.43, 0.47],
        [0.43, 0.58],
        [0.24, 0.58],
      ],
      'h': null,
      'fill': '#E2AE73',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.53, 0.45],
        [0.8, 0.45],
        [0.8, 0.6],
        [0.53, 0.6],
      ],
      'h': null,
      'fill': '#D9A066',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'd',
      'p': [
        [0.57, 0.47],
        [0.76, 0.47],
        [0.76, 0.58],
        [0.57, 0.58],
      ],
      'h': null,
      'fill': '#E2AE73',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.165, 0.62],
        [0.835, 0.62],
        [0.835, 0.982],
        [0.165, 0.982],
      ],
      'h': [
        [0.2, 0.65],
        [0.8, 0.65],
        [0.8, 0.96],
        [0.2, 0.96],
      ],
      'fill': '#B07A4F',
      'st': '#8E5A30',
      'sw': 0.8,
    },
    {
      'f': 'd',
      'p': [
        [0.85, 0.47],
        [0.93, 0.47],
        [0.93, 0.6],
        [0.85, 0.6],
      ],
      'h': null,
      'fill': '#8E5A30',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'd',
      'p': [
        [0.9263, 0.535],
        [0.9194, 0.545],
        [0.9012, 0.5512],
        [0.8788, 0.5512],
        [0.8606, 0.545],
        [0.8537, 0.535],
        [0.8606, 0.525],
        [0.8788, 0.5188],
        [0.9012, 0.5188],
        [0.9194, 0.525],
      ],
      'h': null,
      'fill': '#FFC83D',
      'st': '#C98F00',
      'sw': 0.8,
    },
    {
      'f': 'l',
      'p': [
        [0.0, 0.0],
        [1.0, 0.0],
        [1.0, 1.0],
        [0.0, 1.0],
      ],
      'h': [
        [0.2, 0.65],
        [0.8, 0.65],
        [0.8, 0.96],
        [0.2, 0.96],
      ],
      'fill': '#C38C5C',
      'st': '#A9744A',
      'sw': 1.2,
    },
    {
      'f': 'l',
      'p': [
        [0.0, 0.0],
        [0.055, 0.0],
        [0.055, 1.0],
        [0.0, 1.0],
      ],
      'h': null,
      'fill': '#B07A4F',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.945, 0.0],
        [1.0, 0.0],
        [1.0, 1.0],
        [0.945, 1.0],
      ],
      'h': null,
      'fill': '#CC976A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.17, 0.085],
        [0.83, 0.085],
        [0.83, 0.395],
        [0.17, 0.395],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'l',
      'p': [
        [0.225, 0.12],
        [0.775, 0.12],
        [0.775, 0.36],
        [0.225, 0.36],
      ],
      'h': null,
      'fill': '#FCE6C8',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.5977, 0.2],
        [0.5846, 0.2229],
        [0.5489, 0.2397],
        [0.5, 0.2458],
        [0.4511, 0.2397],
        [0.4154, 0.2229],
        [0.4023, 0.2],
        [0.4154, 0.1771],
        [0.4511, 0.1603],
        [0.5, 0.1542],
        [0.5489, 0.1603],
        [0.5846, 0.1771],
      ],
      'h': null,
      'fill': '#FFE39A',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.225, 0.3],
        [0.775, 0.3],
        [0.775, 0.36],
        [0.225, 0.36],
      ],
      'h': null,
      'fill': '#E3BC86',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.225, 0.12],
        [0.33, 0.12],
        [0.29, 0.36],
        [0.225, 0.36],
      ],
      'h': null,
      'fill': '#F4B48C',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.775, 0.12],
        [0.67, 0.12],
        [0.71, 0.36],
        [0.775, 0.36],
      ],
      'h': null,
      'fill': '#F4B48C',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.49, 0.12],
        [0.51, 0.12],
        [0.51, 0.36],
        [0.49, 0.36],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.225, 0.235],
        [0.775, 0.235],
        [0.775, 0.248],
        [0.225, 0.248],
      ],
      'h': null,
      'fill': '#FFFBF3',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.15, 0.39],
        [0.85, 0.39],
        [0.85, 0.41],
        [0.15, 0.41],
      ],
      'h': null,
      'fill': '#B07A4F',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.2, 0.45],
        [0.47, 0.45],
        [0.47, 0.6],
        [0.2, 0.6],
      ],
      'h': null,
      'fill': '#CF975F',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'l',
      'p': [
        [0.24, 0.47],
        [0.43, 0.47],
        [0.43, 0.58],
        [0.24, 0.58],
      ],
      'h': null,
      'fill': '#D8A46D',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.53, 0.45],
        [0.8, 0.45],
        [0.8, 0.6],
        [0.53, 0.6],
      ],
      'h': null,
      'fill': '#CF975F',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'f': 'l',
      'p': [
        [0.57, 0.47],
        [0.76, 0.47],
        [0.76, 0.58],
        [0.57, 0.58],
      ],
      'h': null,
      'fill': '#D8A46D',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.165, 0.62],
        [0.835, 0.62],
        [0.835, 0.982],
        [0.165, 0.982],
      ],
      'h': [
        [0.2, 0.65],
        [0.8, 0.65],
        [0.8, 0.96],
        [0.2, 0.96],
      ],
      'fill': '#B07A4F',
      'st': '#8E5A30',
      'sw': 0.8,
    },
    {
      'f': 'l',
      'p': [
        [0.85, 0.47],
        [0.93, 0.47],
        [0.93, 0.6],
        [0.85, 0.6],
      ],
      'h': null,
      'fill': '#8E5A30',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'f': 'l',
      'p': [
        [0.9263, 0.535],
        [0.9194, 0.545],
        [0.9012, 0.5512],
        [0.8788, 0.5512],
        [0.8606, 0.545],
        [0.8537, 0.535],
        [0.8606, 0.525],
        [0.8788, 0.5188],
        [0.9012, 0.5188],
        [0.9194, 0.525],
      ],
      'h': null,
      'fill': '#FFC83D',
      'st': '#C98F00',
      'sw': 0.8,
    },
  ],
  'FL': [
    {
      'p': [
        [0.0, 0.0],
        [1.0, 0.0],
        [1.0, 1.0],
        [0.0, 1.0],
      ],
      'fill': '#E2B07A',
      'st': '#B07A4F',
      'sw': 1.0,
    },
    {
      'p': [
        [0.0, 0.0],
        [1.0, 0.0],
        [1.0, 0.1],
        [0.0, 0.1],
      ],
      'fill': '#8E5A30',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.06, 0.86],
        [0.94, 0.86],
        [0.94, 0.94],
        [0.06, 0.94],
      ],
      'fill': '#D9A066',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.6396, 0.58],
        [0.6209, 0.6433],
        [0.5698, 0.6897],
        [0.5, 0.7066],
        [0.4302, 0.6897],
        [0.3791, 0.6433],
        [0.3604, 0.58],
        [0.3791, 0.5167],
        [0.4302, 0.4703],
        [0.5, 0.4534],
        [0.5698, 0.4703],
        [0.6209, 0.5167],
      ],
      'fill': '#C99466',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.3605, 0.4],
        [0.3428, 0.4388],
        [0.3, 0.4549],
        [0.2572, 0.4388],
        [0.2395, 0.4],
        [0.2572, 0.3612],
        [0.3, 0.3451],
        [0.3428, 0.3612],
      ],
      'fill': '#C99466',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.4805, 0.3],
        [0.4628, 0.3388],
        [0.42, 0.3549],
        [0.3772, 0.3388],
        [0.3595, 0.3],
        [0.3772, 0.2612],
        [0.42, 0.2451],
        [0.4628, 0.2612],
      ],
      'fill': '#C99466',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.6405, 0.3],
        [0.6228, 0.3388],
        [0.58, 0.3549],
        [0.5372, 0.3388],
        [0.5195, 0.3],
        [0.5372, 0.2612],
        [0.58, 0.2451],
        [0.6228, 0.2612],
      ],
      'fill': '#C99466',
      'st': 'none',
      'sw': 0.0,
    },
    {
      'p': [
        [0.7605, 0.4],
        [0.7428, 0.4388],
        [0.7, 0.4549],
        [0.6572, 0.4388],
        [0.6395, 0.4],
        [0.6572, 0.3612],
        [0.7, 0.3451],
        [0.7428, 0.3612],
      ],
      'fill': '#C99466',
      'st': 'none',
      'sw': 0.0,
    },
  ],
};
