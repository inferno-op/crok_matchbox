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


// Constants TAB
#define dE Mandelbulb             // {"label":"Fractal type", "control":"select", "options":["MengerSponge", "SphereSponge", "Mandelbulb", "Mandelbox", "OctahedralIFS", "DodecahedronIFS"]}
uniform int maxIterations; //8             // {"label":"Iterations", "min":1, "max":30, "step":1, "group_label":"Fractal parameters"}
uniform int stepLimit; //60                // {"label":"Max steps", "min":10, "max":300, "step":1}
uniform int aoIterations; // 4              // {"label":"AO iterations", "min":0, "max":10, "step":1}
//#define antialiasing 0.5            // {"label":"Anti-aliasing", "control":"bool", "default":false, "group_label":"Render quality"}
uniform bool antialiasing;
uniform bool render_on_black;
uniform float aa_strength;


// Fractal TAB
uniform float power;                // {"label":"Power",        "min":-20,  "max":20,   "step":0.1,     "default":8,    "group":"Fractal"}
uniform float surfaceDetail;        // {"label":"Detail",   "min":0.1,  "max":2,    "step":0.01,    "default":0.6,  "group":"Fractal"}
uniform float surfaceSmoothness;    // {"label":"Smoothness",   "min":0.01,  "max":1,    "step":0.01,    "default":0.8,  "group":"Fractal"}
uniform float boundingRadius;       // {"label":"Bounding radius", "min":0.1, "max":150, "step":0.01, "default":5, "group":"Fractal"}

uniform vec3  offset;               // {"label":["Offset x","Offset y","Offset z"],  "min":-3,   "max":3,    "step":0.01,    "default":[0,0,0],  "group":"Fractal", "group_label":"Offsets"}
// uniform mat3  objectRotation;       // {"label":["Rotate x", "Rotate y", "Rotate z"], "group":"Fractal", "control":"rotation", "default":[0,0,0], "min":-360, "max":360, "step":1, "group_label":"Object rotation"}
uniform vec3 objRotation;
uniform float juliaFactor; // {"label":"Juliabulb factor", "min":0, "max":1, "step":0.01, "default":0, "group":"Fractal", "group_label":"Additional parameters"}
uniform float radiolariaFactor; // {"label":"Radiolaria factor", "min":-2, "max":2, "step":0.1, "default":0, "group":"Fractal"}
uniform float radiolaria;       // {"label":"Radiolaria", "min":0, "max":1, "step":0.01, "default": 0, "group":"Fractal"}

// Camera TAB
uniform float cameraRoll;           // {"label":"Roll",         "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera", "group_label":"Camera parameters"}
uniform float cameraPitch;          // {"label":"Pitch",        "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera"}
uniform float cameraYaw;            // {"label":"Yaw",          "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera"}
uniform float cameraFocalLength;    // {"label":"Focal length", "min":0.1,  "max":3,    "step":0.01,    "default":0.9,  "group":"Camera"}
uniform vec3  cameraPosition;       // {"label":["Camera x", "Camera y", "Camera z"],   "default":[0.0, 0.0, -2.5], "control":"camera", "group":"Camera", "group_label":"Position"}

// Colour TAB
uniform int   colorIterations;      // {"label":"Colour iterations", "default": 4, "min":0, "max": 30, "step":1, "group":"Colour", "group_label":"Base colour"}
uniform vec3  color1;               // {"label":"Colour 1",  "default":[1.0, 1.0, 1.0], "group":"Colour", "control":"color"}
uniform float color1Intensity;      // {"label":"Colour 1 intensity", "default":0.45, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform vec3  color2;               // {"label":"Colour 2",  "default":[0, 0.53, 0.8], "group":"Colour", "control":"color"}
uniform float color2Intensity;      // {"label":"Colour 2 intensity", "default":0.3, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform vec3  color3;               // {"label":"Colour 3",  "default":[1.0, 0.53, 0.0], "group":"Colour", "control":"color"}
uniform float color3Intensity;      // {"label":"Colour 3 intensity", "default":0, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform float ambientColor;         // {"label":["Ambient intensity", "Ambient colour"],  "default":[0.5, 0.3], "group":"Colour", "group_label":"Ambient light & background"}
uniform float ambientIntensity;
uniform vec3  background1Color;     // {"label":"Background top",   "default":[0.0, 0.46, 0.8], "group":"Colour", "control":"color"}
uniform vec3  background2Color;     // {"label":"Background bottom", "default":[0, 0, 0], "group":"Colour", "control":"color"}

// Shading TAB
uniform vec3  light;                // {"label":["Light x", "Light y", "Light z"], "default":[-16.0, 100.0, -60.0], "min":-300, "max":300,  "step":1,   "group":"Shading", "group_label":"Light position"}
uniform vec3  innerGlowColor;       // {"label":"Inner glow", "default":[0.0, 0.6, 0.8], "group":"Shading", "control":"color", "group_label":"Glows"}
uniform float innerGlowIntensity;   // {"label":"Inner glow intensity", "default":0.1, "min":0, "max":1, "step":0.01, "group":"Shading"}
uniform vec3  outerGlowColor;       // {"label":"Outer glow", "default":[1.0, 1.0, 1.0], "group":"Shading", "control":"color"}
uniform float outerGlowIntensity;   // {"label":"Outer glow intensity", "default":0.0, "min":0, "max":1, "step":0.01, "group":"Shading"}
uniform float fog;                  // {"label":"Fog intensity",          "min":0,    "max":1,    "step":0.01,    "default":0,    "group":"Shading", "group_label":"Fog"}
uniform float fogFalloff;           // {"label":"Fog falloff",  "min":0,    "max":10,   "step":0.01,    "default":0,    "group":"Shading"}
uniform float specularity;          // {"label":"Specularity",  "min":0,    "max":3,    "step":0.01,    "default":0.8,  "group":"Shading", "group_label":"Shininess"}
uniform float specularExponent;     // {"label":"Specular exponent", "min":0, "max":50, "step":0.1,     "default":4,    "group":"Shading"}
uniform float aoIntensity;          // {"label":"AO intensity",     "min":0, "max":1, "step":0.01, "default":0.15,  "group":"Shading", "group_label":"Ambient occlusion"}
uniform float aoSpread;             // {"label":"AO spread",    "min":0, "max":20, "step":0.01, "default":9,  "group":"Shading"}


uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);




// uniform mat3  fractalRotation1;     // {"label":["Rotate x", "Rotate y", "Rotate z"], "group":"Fractal", "control":"rotation", "default":[0,0,0], "min":-360, "max":360, "step":1, "group_label":"Fractal rotation 1"}
//uniform vec3 fracRotation1;
uniform bool  depthMap;             // {"label":"Depth map", "default": false, "value":1, "group":"Shading"}



// start for Flame compatibility reason
#define pi 3.1415926535897932384624433832795

// Degrees to radians
float deg2rad(float angle) 
{
	return(angle/(180.0/pi));
}
// Rotates in ZXY order
float x = deg2rad(objRotation.x);
float y = deg2rad(objRotation.y);
float z = deg2rad(objRotation.z);
mat3 rx = mat3(1.0, 0.0, 0.0, 0.0, cos(x), sin(x), 0.0, -sin(x), cos(x));
mat3 ry = mat3(cos(y), 0.0, -sin(y), 0.0, 1.0, 0.0, sin(y), 0.0, cos(y));
mat3 rz = mat3(cos(z), sin(z), 0.0, -sin(z), cos(z), 0.0, 0.0, 0.0, 1.0);
mat3 objectRotation = ry * rx * rz;

// Rotates in ZXY order
//float fracx = deg2rad(fracRotation1.x);
//float fracy = deg2rad(fracRotation1.y);
//float fracz = deg2rad(fracRotation1.z);
//mat3 fracrx = mat3(1.0, 0.0, 0.0, 0.0, cos(fracx), sin(fracx), 0.0, -sin(fracx), cos(fracx));
//mat3 fracry = mat3(cos(fracy), 0.0, -sin(fracy), 0.0, 1.0, 0.0, sin(fracy), 0.0, cos(fracy));
//mat3 fracrz = mat3(cos(fracz), sin(fracz), 0.0, -sin(fracz), cos(fracz), 0.0, 0.0, 0.0, 1.0);
//mat3 fractalRotation1 = fracry * fracrx * fracrz;

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



// Scalar derivative approach by Enforcer:
// http://www.fractalforums.com/mandelbulb-implementation/realtime-renderingoptimisations/
void powN(float p, inout vec3 z, float zr0, inout float dr)
{
    float zo0 = asin(z.z / zr0);
    float zi0 = atan(z.y, z.x);
    float zr = pow(zr0, p - 1.0);
    float zo = zo0 * p;
    float zi = zi0 * p;
    float czo = cos(zo);

    dr = zr * dr * p + 1.0;
    zr *= zr0;

    z = zr * vec3(czo * cos(zi), czo * sin(zi), sin(zo));
}

vec3 Mandelbulb(vec3 w)
{
    w *= objectRotation;
    
    vec3 z = w;
    vec3 c = mix(w, offset, juliaFactor);
    vec3 d = w;
    float dr = 1.0;
    float r  = length(z);
    float md = 10000.0;
    
    for (int i = 0; i < int(maxIterations); i++) {
        powN(power, z, r, dr);
        
        z += c;
            
        if (z.y > radiolariaFactor) {
            z.y = mix(z.y, radiolariaFactor, radiolaria);
        }
        
        r = length(z);
        
        if (i < colorIterations) {
            md = min(md, r);
            d = z;
        }
        
        if (r > bailout) break;
    }

    return vec3(0.5 * log(r) * r / dr, md, 0.33 * log(dot(d, d)) + 1.0);
}



// ============================================================================================ //



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

vec3 matte = vec3(0.0);
vec4 bg_color = vec4(0.0);


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


// Calculate the output colour for each input pixel
vec4 render(vec2 pixel)
{
    vec3  ray_direction = rayDirection(pixel);
    float ray_length = minRange;
    vec3  ray = cameraPosition + ray_length * ray_direction;
	if (render_on_black )
		bg_color = vec4(clamp(mix(vec3(0.0), vec3(0.0), (sin(ray_direction.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0), 1.0);
	else
		bg_color = vec4(clamp(mix(background2Color, background1Color, (sin(ray_direction.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0), 1.0);
    vec4  color = vec4(0.0);
    
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
		if (render_on_black )
		{
			bg_color.rgb = mix(vec3(0.0), color.rgb, exp(-pow(ray_length * exp(fogFalloff * .1), 2.0)) * fog * .1);
		}
		else
		{
			color.rgb = mix(bg_color.rgb, color.rgb, exp(-pow(ray_length * exp(fogFalloff * .1), 2.0)) * fog * .1);
	        glow = clamp(glowAmount * outerGlowIntensity * 3.0, 0.0, 1.0);
	        color.rgb = mix(color.rgb, outerGlowColor, glow);
		}


    }
	

    
    return color;
}


// ============================================================================================ //


// The main loop
void main()
{
    vec4 color = vec4(0.0);
	
    float n = 0.0;
    
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
