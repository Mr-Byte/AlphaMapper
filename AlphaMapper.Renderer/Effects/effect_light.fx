// Copyright 2013 Joshua R. Rodgers
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ========================================================================

static const float SHADOW_EPSILON = 0.0005f;
static const float SMAP_SIZE = 4096.0f;
static const float SMAP_DX = 1.0f / SMAP_SIZE;

struct Light
{
	float3 direction;
	float4 ambient;
	float4 diffuse;
};

Texture2D g_ShadowMap;

SamplerComparisonState g_ShadowMapSampler
{
 // sampler state
   Filter = COMPARISON_MIN_MAG_MIP_LINEAR;
   AddressU = CLAMP;
   AddressV = CLAMP;

   // sampler comparison state
   ComparisonFunc = LESS_EQUAL;
};

float2 texOffset( int u, int v )
{
    return float2( u * 1.0f/SMAP_SIZE, v * 1.0f/SMAP_SIZE );
}

float CalcShadowFactor(float4 projTexC)
{
	// Complete projection by doing division by w.
	projTexC.xyz /= projTexC.w;
	
	// Points outside the light volume are in shadow.
	if( projTexC.x < -1.0f || projTexC.x > 1.0f || 
	    projTexC.y < -1.0f || projTexC.y > 1.0f ||
	    projTexC.z < 0.0f )
	    return 0.0f;
	    
	// Transform from NDC space to texture space.
	projTexC.x = +0.5f*projTexC.x + 0.5f;
	projTexC.y = -0.5f*projTexC.y + 0.5f;
	
	// Sample shadow map to get nearest depth to light.
	float sum = 0;
    float x, y;
	int count = 0;
	const float bound = 1.5f;

    for (y = -bound; y <= bound; y += 1.0)
    {
        for (x = -bound; x <= bound; x += 1.0)
        {
			count++;
            sum += g_ShadowMap.SampleCmpLevelZero(g_ShadowMapSampler, projTexC.xy + texOffset(x,y), projTexC.z - SHADOW_EPSILON);
        }
    }

	return sum/count;
}

float4 ParallelLight(float3 color, float3 normal, float ambient, float diffuse, Light light, float shadowFactor)
{
	float4 litColor = float4(0, 0, 0, 1);
	float3 lightVector = -light.direction;
	float diffuseFactor = saturate(dot(normal, lightVector));

	litColor +=  float4(ambient * color * (float3)light.ambient, 1);

	[branch]
	if(diffuseFactor > 0.0f)
	{
		litColor += float4(float3(diffuse * color * diffuseFactor * (float3)light.diffuse) * shadowFactor, 1);
	}

	return litColor;
}
