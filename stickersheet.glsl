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

