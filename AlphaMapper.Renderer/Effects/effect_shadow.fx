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

cbuffer cbPerObject
{
    float4x4 g_WorldMatrix;
	bool g_IsInstanced = false;
};

cbuffer cbPerMaterial
{
	bool g_HasMask;
}

cbuffer cbPerLight
{
	float4x4 g_LightViewProjectionMatrix;
};

struct VS_ShadowStandard
{
    float3 position : POSITION;
	float2 uv : TEXCOORD;
    float3 normal : NORMAL;
	float4x4 worldMatrix : TRANSFORM;
};

struct VS_ShadowPrelit
{
    float3 position : POSITION;
    float2 uv : TEXCOORD;
    float3 normal : NORMAL;
    float3 color : COLOR;
	float4x4 worldMatrix : TRANSFORM;
};

struct PS_Shadow
{
	float4 position : SV_POSITION;
	float2 uv : TEXCOORD;
};

//Texture sampler
SamplerState g_TextureSampler
{
	Filter = ANISOTROPIC;
	AddressU = WRAP;
	AddressV = WRAP;
};

//Texture and mask
Texture2D g_Mask;

PS_Shadow VShaderShadowMapStandard(VS_ShadowStandard input)
{
	PS_Shadow output;
	
	output.uv = input.uv;

	[branch]
	if(g_IsInstanced)
	{
		output.position = mul(mul(float4(input.position, 1.0f), input.worldMatrix), g_LightViewProjectionMatrix);
	}
	else
	{
		output.position = mul(mul(float4(input.position, 1.0f), g_WorldMatrix), g_LightViewProjectionMatrix);
	}

	return output;
}

PS_Shadow VShaderShadowMapPrelit(VS_ShadowPrelit input)
{
	PS_Shadow output;

	output.uv = input.uv;

	[branch]
	if(g_IsInstanced)
	{
		output.position = mul(mul(float4(input.position, 1.0f), input.worldMatrix), g_LightViewProjectionMatrix);
	}
	else
	{
		output.position = mul(mul(float4(input.position, 1.0f), g_WorldMatrix), g_LightViewProjectionMatrix);
	}

	return output;
}

void PShaderShadowMap(PS_Shadow input) 
{
	[branch]
	if(g_HasMask)
	{
		clip(g_Mask.Sample(g_TextureSampler, input.uv).r - 0.2f);
	}
}

fxgroup ShadowMapTechnique
{
	technique11 Standard
	{
		pass p0
		{
			SetVertexShader( CompileShader( vs_4_0, VShaderShadowMapStandard() ) );
			SetGeometryShader( NULL );
			SetPixelShader( CompileShader( ps_4_0, PShaderShadowMap() ) );
		}
	}

	technique11 Prelit
	{
		pass p0
		{
			SetVertexShader( CompileShader( vs_4_0, VShaderShadowMapPrelit() ) );
			SetGeometryShader( NULL );
			SetPixelShader( CompileShader( ps_4_0, PShaderShadowMap() ) );
		}
	}
}
