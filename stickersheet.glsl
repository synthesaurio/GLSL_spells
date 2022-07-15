// This is a stickersheet for some common functions that I use, a lot of this has been ripped from others amazing people work and I will try to link their profiles in the description

// ~~~~~~~~~~ | Utility | ~~~~~~~~~~
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

