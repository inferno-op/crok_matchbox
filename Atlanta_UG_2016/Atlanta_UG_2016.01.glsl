// based on http://hirnsohle.de/test/fractalLab/
/**
 * Fractal Lab's uber 3D fractal shader
 * Last update: 26 February 2011
 *
 * Changelog:
 *      0.1     - Initial release
 *      0.2     - Refactor for Fractal Lab
 *
 * 
 * Copyright 2011, Tom Beddard
 * http://www.subblue.com
 *
 * For more generative graphics experiments see:
 * http://www.subblue.com
 *
 * Licensed under the GPL Version 3 license.
 * http://www.gnu.org/licenses/
 *
 * 
 * Credits and references
 * ======================
 * 
 * http://www.fractalforums.com/3d-fractal-generation/a-mandelbox-distance-estimate-formula/
 * http://www.fractalforums.com/3d-fractal-generation/revenge-of-the-half-eaten-menger-sponge/msg21700/
 * http://www.fractalforums.com/index.php?topic=3158.msg16982#msg16982
 * 
 * Various other discussions on the fractal can be found here:
 * http://www.fractalforums.com/3d-fractal-generation/
 *
 *
*/

#define HALFPI 1.570796
#define MIN_EPSILON 6e-7
#define MIN_NORM 1.5e-7
#define minRange 6e-5
#define bailout 4.0

// first variation


// Constants TAB
#define dE Mandelbox             
int maxIterations = 12; //8             // {"label":"Iterations", "min":1, "max":30, "step":1, "group_label":"Fractal parameters"}
int stepLimit = 96; //60                // {"label":"Max steps", "min":10, "max":300, "step":1}
int aoIterations = 4; // 4              // {"label":"AO iterations", "min":0, "max":10, "step":1}
uniform bool antialiasing;
uniform float aa_strength;
uniform float t_offset;

// Fractal TAB
float scale = 2.59; 
float surfaceDetail = 0.68;
float surfaceSmoothness = 1.0; 
float boundingRadius = 112.68; 
vec3 offset = vec3(0.0, 0.0, 5.710); 
vec3 objRotation = vec3(0.0, 0.0, 0.0);
vec3 fracRotation1 = vec3(0.0, 0.0, 0.0);   
vec3 fracRotation2 = vec3(0.0, 0.0, 0.0);    
float sphereScale = 1.0;          
float boxScale = 0.44; 
float boxFold = 1.08; 
float fudgeFactor = 0.0;

// Camera TAB
float cameraRoll = 0.0;           
float cameraPitch = 0.0;          
float cameraYaw = 0.0;            
float cameraFocalLength = 0.9;    
vec3  cameraPosition = vec3(0.0, 0.0, -1.950);      

// Colour TAB
int   colorIterations = 3;      
vec3  color1 = vec3(1.0, 1.0, 1.0);  
float color1Intensity = 2.0;     
vec3  color2 = vec3(0.0, 0.0, 0.0);     
float color2Intensity = 0.0;
vec3  color3 = vec3(0.0, 0.0, 0.0);     
float color3Intensity = 0.0; 
float ambientColor = 0.52;
float ambientIntensity = 1.01;
vec3  background1Color = vec3(1.0, 1.0, 1.0);    
vec3  background2Color = vec3(0.7, 0.7, 0.7);

// Shading TAB
vec3  light = vec3(0.0, 234.8, 312.8);
vec3  innerGlowColor = vec3(0.0);
float innerGlowIntensity = 0.0;
vec3  outerGlowColor = vec3(0.0); 
float outerGlowIntensity = 0.0;
float fog = 1.08;  
float fogFalloff = 1.41;
float specularity = 10.0; 
float specularExponent = 4.0;
float aoIntensity = 0.38;
float aoSpread = 9.0;

uniform float adsk_result_w, adsk_result_h, adsk_time;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
float time = adsk_time*.01;

// start for Flame compatibility reason
#define pi 3.1415926535897932384624433832795

// Degrees to radians
float deg2rad(float angle) 
{
	return(angle/(180.0/pi));
}
// Rotates in ZXY order
float x = deg2rad(objRotation.x) * time;
float y = deg2rad(objRotation.y);
float z = deg2rad(objRotation.z);
mat3 rx = mat3(1.0, 0.0, 0.0, 0.0, cos(x), sin(x), 0.0, -sin(x), cos(x));
mat3 ry = mat3(cos(y), 0.0, -sin(y), 0.0, 1.0, 0.0, sin(y), 0.0, cos(y));
mat3 rz = mat3(cos(z), sin(z), 0.0, -sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
mat3 objectRotation = ry * rx * rz;

// Rotates in ZXY order
float frac1x = deg2rad(fracRotation1.x);
float frac1y = deg2rad(fracRotation1.y);
float frac1z = deg2rad(fracRotation1.z);
mat3 fracr1x = mat3(1.0, 0.0, 0.0, 0.0, cos(frac1x), sin(frac1x), 0.0, -sin(frac1x), cos(frac1x));
mat3 fracr1y = mat3(cos(frac1y), 0.0, -sin(frac1y), 0.0, 1.0, 0.0, sin(frac1y), 0.0, cos(frac1y));
mat3 fracr1z = mat3(cos(frac1z), sin(frac1z), 0.0, -sin(frac1z), cos(frac1z), 0.0, 0.0, 0.0, 1.0);
mat3 fractalRotation1 = fracr1y * fracr1x * fracr1z;

// Rotates in ZXY order
float frac2x = deg2rad(fracRotation2.x);
float frac2y = deg2rad(fracRotation2.y);
float frac2z = deg2rad(fracRotation2.z);
mat3 fracr2x = mat3(1.0, 0.0, 0.0, 0.0, cos(frac2x), sin(frac2x), 0.0, -sin(frac2x), cos(frac2x));
mat3 fracr2y = mat3(cos(frac2y), 0.0, -sin(frac2y), 0.0, 1.0, 0.0, sin(frac2y), 0.0, cos(frac2y));
mat3 fracr2z = mat3(cos(frac2z), sin(frac2z), 0.0, -sin(frac2z), cos(frac2z), 0.0, 0.0, 0.0, 1.0);
mat3 fractalRotation2 = fracr2y * fracr2x * fracr2z;
// end for Flame compatibility reason



float aspectRatio = resolution.x / resolution.y;
float fovfactor = 1.0 / sqrt(1.0 + cameraFocalLength * cameraFocalLength);
float pixelScale = 1.0 / min(resolution.x, resolution.y);
float epsfactor = 2.0 * fovfactor * pixelScale * surfaceDetail;
vec3  w = vec3(0, 0, 1);
vec3  v = vec3(0, 1, 0);
vec3  u = vec3(1, 0, 0);
mat3  cameraRotation;


// Return rotation matrix for rotating around vector v by angle
mat3 rotationMatrixVector(vec3 v, float angle)
{
    float c = cos(radians(angle));
    float s = sin(radians(angle));
    
    return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
              (1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
              (1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z);
}



// Pre-calculations
float mR2 = boxScale * boxScale;    // Min radius
float fR2 = sphereScale * mR2;      // Fixed radius

// float blend_anim = abs(sin(cut_time));
//float scale_anim = smoothstep(0.19, 1.0, time * 10.);
//float scale_anim = smoothstep(0.99, 1.0, time * 0.01) *scale;
vec2  scaleFactor = vec2(scale) / mR2;


// Details about the Mandelbox DE algorithm:
// http://www.fractalforums.com/3d-fractal-generation/a-mandelbox-distance-estimate-formula/
vec3 Mandelbox(vec3 w)
{
    w *= objectRotation;
    float md = 1000.0;
    vec3 c = w;
    
    // distance estimate
    vec4 p = vec4(w.xyz, 1.0),
        p0 = vec4(w.xyz, 1.0);  // p.w is knighty's DEfactor
    
    for (int i = 0; i < int(maxIterations); i++) {
        // box fold:
        // if (p > 1.0) {
        //   p = 2.0 - p;
        // } else if (p < -1.0) {
        //   p = -2.0 - p;
        // }
        p.xyz = clamp(p.xyz, -boxFold, boxFold) * 2.0 * boxFold - p.xyz;  // box fold
        p.xyz *= fractalRotation1;
        
        // sphere fold:
        // if (d < minRad2) {
        //   p /= minRad2;
        // } else if (d < 1.0) {
        //   p /= d;
        // }
        float d = dot(p.xyz, p.xyz);
        p.xyzw *= clamp(max(fR2 / d, mR2), 0.0, 1.0);  // sphere fold
        
        p.xyzw = p * scaleFactor.xxxy + p0 + vec4(vec3(0.0, 0.0, offset.z * 0.03), 0.0);
        p.xyz *= fractalRotation2;

        if (i < colorIterations) {
            md = min(md, d);
            c = p.xyz;
        }
    }
    
    // Return distance estimate, min distance, fractional iteration count
    return vec3((length(p.xyz) - fudgeFactor) / p.w, md, 0.33 * log(dot(c, c)) + 1.0);
}

 
// Define the ray direction from the pixel coordinates
vec3 rayDirection(vec2 pixel)
{
    vec2 p = (0.5 * resolution - pixel) / vec2(resolution.x, -resolution.y);
    p.x *= aspectRatio;
    vec3 d = (p.x * u + p.y * v - cameraFocalLength * w);
    
    return normalize(cameraRotation * d);
}



// Intersect bounding sphere
//
// If we intersect then set the tmin and tmax values to set the start and
// end distances the ray should traverse.
bool intersectBoundingSphere(vec3 origin,
                             vec3 direction,
                             out float tmin,
                             out float tmax)
{
    bool hit = false;
    float b = dot(origin, direction);
    float c = dot(origin, origin) - boundingRadius;
    float disc = b*b - c;           // discriminant
    tmin = tmax = 0.0;

    if (disc > 0.0) {
        // Real root of disc, so intersection
        float sdisc = sqrt(disc);
        float t0 = -b - sdisc;          // closest intersection distance
        float t1 = -b + sdisc;          // furthest intersection distance

        if (t0 >= 0.0) {
            // Ray intersects front of sphere
            tmin = t0;
            tmax = t0 + t1;
        } else if (t0 < 0.0) {
            // Ray starts inside sphere
            tmax = t1;
        }
        hit = true;
    }

    return hit;
}




// Calculate the gradient in each dimension from the intersection point
vec3 generateNormal(vec3 z, float d)
{
    float e = max(d * 0.5, MIN_NORM);
    
    float dx1 = dE(z + vec3(e, 0, 0)).x;
    float dx2 = dE(z - vec3(e, 0, 0)).x;
    
    float dy1 = dE(z + vec3(0, e, 0)).x;
    float dy2 = dE(z - vec3(0, e, 0)).x;
    
    float dz1 = dE(z + vec3(0, 0, e)).x;
    float dz2 = dE(z - vec3(0, 0, e)).x;
    
    return normalize(vec3(dx1 - dx2, dy1 - dy2, dz1 - dz2));
}


// Blinn phong shading model
// http://en.wikipedia.org/wiki/BlinnPhong_shading_model
// base color, incident, point of intersection, normal
vec3 blinnPhong(vec3 color, vec3 p, vec3 n)
{
    // Ambient colour based on background gradient
    vec3 ambColor = clamp(mix(background2Color, background1Color, (sin(n.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0);
    ambColor = mix(vec3(ambientColor), ambColor, ambientIntensity);
    
    vec3  halfLV = normalize(light - p);
    float diffuse = max(dot(n, halfLV), 0.0);
    float specular = pow(diffuse, specularExponent);
    
    return ambColor * color + color * diffuse + specular * specularity;
}

// Ambient occlusion approximation.
// Based upon boxplorer's implementation which is derived from:
// http://www.iquilezles.org/www/material/nvscene2008/rwwtt.pdf
float ambientOcclusion(vec3 p, vec3 n, float eps)
{
    float o = 1.0;                  // Start at full output colour intensity
    eps *= aoSpread;                // Spread diffuses the effect
    float k = aoIntensity / eps;    // Set intensity factor
    float d = 2.0 * eps;            // Start ray a little off the surface
    
    for (int i = 0; i < aoIterations; ++i) {
        o -= (d - dE(p + n * d).x) * k;
        d += eps;
        k *= 0.5;                   // AO contribution drops as we move further from the surface 
    }
    
    return clamp(o, 0.0, 1.0);
}

vec3 z_depth = vec3(0.0);


// Calculate the output colour for each input pixel
vec4 render(vec2 pixel)
{
    vec3  ray_direction = rayDirection(pixel);
    float ray_length = minRange;
    vec3  ray = cameraPosition + ray_length * ray_direction;
    vec4  color = vec4(0.0);

	vec4 bg_color = vec4(clamp(mix(background2Color, background1Color, (sin(ray_direction.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0), 1.0);
	  
    float eps = MIN_EPSILON;
    vec3  dist;
    vec3  normal = vec3(0);
    int   steps = 0;
    bool  hit = false;
    float tmin = 0.0;
    float tmax = 10000.0;
	
    
    if (intersectBoundingSphere(ray, ray_direction, tmin, tmax)) {
        ray_length = tmin;
        ray = cameraPosition + ray_length * ray_direction;
        
        for (int i = 0; i < stepLimit; i++) {
            steps = i;
            dist = dE(ray);
            dist.x *= surfaceSmoothness;
            
            // If we hit the surface on the previous step check again to make sure it wasn't
            // just a thin filament
            if (hit && dist.x < eps || ray_length > tmax || ray_length < tmin) {
                steps--;
                break;
            }
            
            hit = false;
            ray_length += dist.x;
            ray = cameraPosition + ray_length * ray_direction;
            eps = ray_length * epsfactor;

            if (dist.x < eps || ray_length < tmin) {
                hit = true;
            }
        }
    }
    
    // Found intersection?
    float glowAmount = float(steps)/float(stepLimit);
    float glow;
    
    if (hit) {
        float aof = 1.0, shadows = 1.0;
        glow = clamp(glowAmount * innerGlowIntensity * 3.0, 0.0, 1.0);

        if (steps < 1 || ray_length < tmin) {
            normal = normalize(ray);
        } else {
            normal = generateNormal(ray, eps);
            aof = ambientOcclusion(ray, normal, eps);
        }

			// creating the matte pass
			color.a = float(mix(color1, mix(color2, color3, 1.0), 1.0));
		
			// creating the beauty pass 
	        color.rgb = mix(color1, mix(color2, color3, dist.y * color2Intensity), dist.z * color3Intensity);
		
			// add shading
			color.rgb = blinnPhong(clamp(color.rgb * color1Intensity, 0.0, 1.0), ray, normal);
        
			// add inner glow
			color.rgb = mix(color.rgb, innerGlowColor, glow);
		
			// add AO
			color.rgb *= aof;
        
			// add fog
			color.rgb = mix(bg_color.rgb, color.rgb, exp(-pow(ray_length * exp(fogFalloff * .1), 2.0) * fog * .1));	

		
    } else {
        // Apply outer glow and fog
        ray_length = tmax;
		color.rgb = mix(bg_color.rgb, color.rgb, exp(-pow(ray_length * exp(fogFalloff * .1), 2.0)) * fog * .1);
		glow = clamp(glowAmount * outerGlowIntensity * 3.0, 0.0, 1.0);
	    color.rgb = mix(color.rgb, outerGlowColor, glow);

    }
	
   
    return color;
}

// The main loop
void main()
{
    vec4 color = vec4(0.0);
	float aa_mulitplier = 1.0;
    float n = 0.0;
    
	// create a demo mode which switch every x seconds to a new mode
	int mode = int(mod(.5*time,11.));
	if      (mode==0) cameraPosition.z += time * 0.01 + 6.11;
	else if (mode==1) cameraPosition.z += time * 0.01 + 6.09;
	else if (mode==2) cameraPosition.z += time * 0.01 + 4.7;
	else if (mode==3) cameraPosition.z += time * 0.01 + 6.0;
	else if (mode==4) cameraPosition.z += time * 0.01 + 6.03;
	else if (mode==5) cameraPosition.z += time * 0.01 + 5.77;
	else if (mode==6) cameraPosition.z += time * 0.01 + 5.99;
	else if (mode==7) cameraPosition.z += time * 0.01 + 4.22;
	else if (mode==8) cameraPosition.z += time * 0.01 + 5.9;
	else if (mode==9) cameraPosition.z += time * 0.01 + 5.70;

	else if (mode==10) cameraPosition.z += time * 0.01 + 5.68;
	
	cameraRotation = rotationMatrixVector(v, 180.0 - cameraYaw) * rotationMatrixVector(u, -cameraPitch) * rotationMatrixVector(w, cameraRoll);

    
	if ( antialiasing )
	{
	    for (float x = 0.0; x < 1.0; x += float(1.0 - aa_strength * .7)) {
	        for (float y = 0.0; y < 1.0; y += float(1.0 - aa_strength * .7)) {
	            color += render(gl_FragCoord.xy + vec2(x, y));
				n += 1.0;
	        }
	    }
	    color /= n;
	}

	else
		color = render(gl_FragCoord.xy);

	gl_FragColor = vec4(color.rgb, color.a);
	
}
