// This is a stickersheet for some common functions that I use, a lot of this has been ripped from others amazing people work and I will try to link their profiles in the description

// ~~~~~~~~~~ | Utility | ~~~~~~~~~~
//uv flip
vec2 uvFlip(vec2 uv){
    vec2 uvf = vec2(uv.x, 1.0 - uv.y);
    return uvf;
}

// color palette
vec3 palette(in vec3 t, in vec3 a, in vec3 b, in vec3 c, in vec3 d){
  return a + b*cos(38.21*(c*t+d) ); 
}

// midi, use:
// float cc1 = 3. * 127. + 1.; // for defining midi cc
// float r = texture2D(u_midi,midiCoord(cc1)).w; // to get the value
vec2 midiCoord(float offset){
    float x = mod(offset,32.);
    float y = offset / 32.;
    return vec2(x,y)/32.;
}

// ~~~~~~~~~~~ |Visual effects| ~~~~~~~~~~

// Watercolor feedback
//adapted from https://www.shadertoy.com/view/Mslczf
vec3 WaterFeedback(vec4 video, vec2 uv){
    vec2 unit = 1. / resolution.xy;
    vec4 frame = texture2D(prevFrame, uv);
    float angle = luminance(frame) * 3.1459 * 2.;
    angle += time * 0.1;
    angle += luminance(video) * 3.14159 * 2.;
    vec2 offset = vec2(cos(angle), sin(angle)) * unit;
    
    frame = texture2D(prevFrame, uv + offset);
    vec3 col = mix(frame, video, smoothstep(0.1, .6, length(video-frame))).rgb;
    
    return col; 
}

//KALEIDOSCOPE
float pModPolar(inout vec2 p, float repetitions) {
    float PI = 3.14;
    float angle = 2.*PI/repetitions;
    float a = atan(p.y, p.x) + angle/2.;
    float r = length(p);
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*r;
    // For an odd number of repetitions, fix cell index of the cell in -x direction
    // (cell index would be e.g. -5 and 5 in the two halves of the cell):
    if (abs(c) >= (repetitions/2.)) c = abs(c);
    return c;
}

// ROTATION
void pR(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// Negative image
void negative(inout vec3 col, float neg){
    col = abs((neg*1.0) - col);
}
// Luma dark
void low_luma(inout vec3 col, float th){
    if((col.r + col.g + col.b)/3.0 < th){
        col = vec3(0.0);
    }
}
// Luma light
void high_luma(inout vec3 col, float th){
    if((col.r + col.g + col.b)/3.0 > th){
        col = vec3(0.0);
    }
}

// Hue Adjust
void hueShift(inout vec3 color, float hueAdjust ){
    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);
    const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);
    hue += hueAdjust;
    Q = chroma * sin (hue);
    I = chroma * cos (hue);
    vec3    yIQ   = vec3 (YPrime, I, Q);
    color =  vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
}


// ~~~~~~~~~| Raymarching |~~~~~~~~

// OPERATORS

// Smooth min
float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0., 1. );
    return mix( b, a, h ) - k*h*(1.0-h);
}

// noise func
float hash( float n ) { return fract(sin(n)*753.5453123); }
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
   
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}


// TEXTURING

// diffuse material
float diffuse (in vec3 light, in vec3 nor) {return clamp(0., 1., dot(nor, light));}
// Define base color
vec3 baseColor (in vec3 pos, in vec3 nor, in vec3 rayDir, in float rayDepth) {
    vec3 color = vec3(.0); 
    float dNR = dot(nor, -rayDir);  
    color = palette(vec3(dNR), vec3(0.3), vec3(0.47), vec3(0.64), vec3(0.1, 0.6, 0.13));
    return color;
}
// Make the shade
vec4 shade (vec3 pos, vec3 rayDir, float rayDepth) {
    vec3 nor = GetNormal(pos);
    
    nor += 0.1 * sin(8. * nor);
    nor = normalize(nor);
    
    vec3 color = palette(
        nor,
        vec3(0.5, 0.8, 0.2), // brightness
        vec3(rayDepth) * 1., // contrast
        vec3(.0), // osc
        vec3(0.0, 0.0, 0.0) // phase
    );
    
    vec3 lightPos = vec3(1., 0.1, 1.64);
    
    float dif = diffuse(lightPos, nor);
    color = dif * baseColor(pos, nor, rayDir, rayDepth);
    vec4 shapeColor = vec4(color, 1.0);

    return shapeColor;
}

// SHAPES

//Sphere
float sdSphere(vec3 p, float s){ return length(p)-s;}
// Box
float sdBox(vec3 p, vec3 s){
   p = abs(p) - s;
   return length(max(p, 0.)) + min(max(p.x, max(p.y, p.z)), 0.0);
}
// Torus
float sdTorus( vec3 p, vec2 t ){return length( vec2(length(p.xz)-t.x,p.y) )-t.y;}
// Hex
float sdHexPrism(vec3 p, vec2 h)
{
    vec3 q = abs(p);

    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    vec2 d = vec2(
       length(p.xy - vec2(clamp(p.x, -k.z*h.x, k.z*h.x), h.x))*sign(p.y - h.x),
       p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
//Pyramid
float sdPyramid(in vec3 p, in float h)
{
    float m2 = h*h + 0.25;
    // symmetry
    p.xz = abs(p.xz);
    p.xz = (p.z>p.x) ? p.zx : p.xz;
    p.xz -= 0.5;
    // project into face plane (2D)
    vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
    float s = max(-q.x,0.0);
    float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
   float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    // recover 3D and scale, and add sign
    return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));;
}

// Gyroid
float sdGyroid(vec3 p, float scale, float thickness, float bias){
   p *= scale;
   float gyr = abs(dot(sin(1.0*p + time*0.6), cos(p.zxy*1.0))-bias)/(scale*3.0) - thickness;
   return gyr;
}
