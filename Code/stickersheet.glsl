// This is a stickersheet for some common functions that I use, a lot of this has been ripped from others amazing people work and I will try to link their profiles in the description

// ~~~~~~~~~~ | Utility | ~~~~~~~~~~
//uv flip
vec2 uvFlip(vec2 uv){
    vec2 uvf = vec2(uv.x, 1.0 - uv.y);
    return uvf;
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

