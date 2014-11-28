#version 120

// based on https://www.shadertoy.com/view/MsSSDd

uniform float adsk_result_w, adsk_result_h;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform float position1, position2, bias, blend;
uniform vec3 color1, color2;
uniform int LogicOp, direction;

float gain = 0.75;

// positioned color node
struct RampNode
{
    float Position; // 0 to 1
    vec3 Color;    
};

// inter-node interpolation using Ken Perlin's Bias and Gain functions
// http://blog.demofox.org/2012/09/24/bias-and-gain-are-your-friend/
struct Interpolator
{
    float Bias; // 0 to 1
	float Gain; // 0 to 1
};
    
#define NUM_NODES 2
RampNode ColorRamp[NUM_NODES];
Interpolator Interpolators[NUM_NODES - 1];

float GetBias(float time, float bias)
{
	return (time / ((((1.0 / bias) - 2.0) * (1.0 - time)) + 1.0));
}

float GetGain(float time, float gain)
{
	if(time < 0.5)
		return GetBias(time * 2.0, gain) / 2.0;
	else
		return GetBias(time * 2.0 - 1.0, 1.0 - gain) / 2.0 + 0.5;
}

void main(void)
{
	float x = 0.0;

	if ( direction == 0 )
	{
		// top to bottom
		x = gl_FragCoord.y / resolution.y;
		x = 1. - x;
		
	    ColorRamp[0].Position = position1;
	    ColorRamp[0].Color = color1;

	    Interpolators[0].Bias = bias;
		Interpolators[0].Gain = gain;    
    
	    ColorRamp[1].Position = position2;    
	    ColorRamp[1].Color = color2;
	}


	if ( direction == 1 )
	{
		x = gl_FragCoord.x / resolution.x;
	
	    ColorRamp[0].Position = position1;
	    ColorRamp[0].Color = color1;

	    Interpolators[0].Bias = bias;
		Interpolators[0].Gain = gain;    
        
	    ColorRamp[1].Position = position2;    
	    ColorRamp[1].Color = color2;

	}

	if ( direction == 2 )
	{
		x = gl_FragCoord.y / resolution.y;
	
	    ColorRamp[0].Position = position1;
	    ColorRamp[0].Color = color1;

	    Interpolators[0].Bias = bias;
		Interpolators[0].Gain = gain;    
        
	    ColorRamp[1].Position = position2;    
	    ColorRamp[1].Color = color2;

	}
	
	if ( direction == 3 )
	{
		x = gl_FragCoord.x / resolution.x;
		x = 1. - x;
			
	    ColorRamp[0].Position = position1;
	    ColorRamp[0].Color = color1;

	    Interpolators[0].Bias = bias;
		Interpolators[0].Gain = gain;    
        
	    ColorRamp[1].Position = position2;    
	    ColorRamp[1].Color = color2;

	}
   
   
    // anything before the first ramp node takes its color
    vec3 d = ColorRamp[0].Color; 
	
  
   	// loop through ramp nodes
    for (int i = 1; i < NUM_NODES; i++)
    {
        RampNode last = ColorRamp[i - 1];
        RampNode current = ColorRamp[i];
        
       	float stepInStage = (x - last.Position) / (current.Position - last.Position);
        
        if (stepInStage < 0.0 || stepInStage >= 1.0)
            // not in the range for this node, keep going
            continue;
        
        // interpolate
        Interpolator interpolator = Interpolators[i - 1];
        stepInStage = GetBias(stepInStage, interpolator.Bias) * 
					  GetGain(stepInStage, interpolator.Gain);
        
        d = mix(last.Color, current.Color, stepInStage);
    }
    
    // anything after the last ramp node takes its color
    if (x > ColorRamp[NUM_NODES - 1].Position)
        d = ColorRamp[NUM_NODES - 1].Color;
 

	gl_FragColor = vec4(d, 1.0);
}