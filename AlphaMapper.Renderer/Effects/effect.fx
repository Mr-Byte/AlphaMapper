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

#include "effect_globals.fx"

RasterizerState g_rasterizerState
{
	Fillmode = Solid;
	FrontCounterClockwise = false;
	CullMode = Front;
};

BlendState g_blendState
{
    AlphaToCoverageEnable = TRUE;
	BlendEnable[0] = TRUE;
    SrcBlend = ONE;
    DestBlend = INV_SRC_ALPHA;
    BlendOp = ADD;
    RenderTargetWriteMask[0] = 0x0F;
};

#define STANDARD
#include "effect_shaders.fx"
fxgroup Standard
{
	technique11 Smooth
	{
		pass p0
		{
			SetRasterizerState(g_rasterizerState);
			SetBlendState(g_blendState, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
			SetVertexShader( CompileShader( vs_5_0, VShaderStandard() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderStandard() ) );
			SetPixelShader( CompileShader( ps_5_0, PShaderStandard() ) );
		}

	}

	technique11 Flat
	{
		pass p0
		{
			SetRasterizerState(g_rasterizerState);
			SetBlendState(g_blendState, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
			SetVertexShader( CompileShader( vs_5_0, VShaderStandard() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderStandard_Flat() ) );
			SetPixelShader( CompileShader( ps_5_0, PShaderStandard() ) );
		}
	}

	technique11 Wireframe
	{
		pass p0
		{
			SetRasterizerState(g_rasterizerState);
			SetVertexShader( CompileShader( vs_5_0, VShaderStandard() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderStandard_Wireframe() ) );
			SetPixelShader( CompileShader( ps_5_0, PShaderStandard() ) );
		}
	}
}
#undef STANDARD

#define PRELIT
#include "effect_shaders.fx"
fxgroup Prelit
{
    technique11 Smooth
	{
        pass p0
		{
			SetRasterizerState(g_rasterizerState);
			SetBlendState(g_blendState, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
            SetVertexShader( CompileShader( vs_5_0, VShaderPrelit() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderPrelit() ) );
            SetPixelShader( CompileShader( ps_5_0, PShaderPrelit() ) );
        }
	}

    technique11 Flat
	{
        pass p0
		{
			SetRasterizerState(g_rasterizerState);
			SetBlendState(g_blendState, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
            SetVertexShader( CompileShader( vs_5_0, VShaderPrelit() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderPrelit_Flat() ) );
            SetPixelShader( CompileShader( ps_5_0, PShaderPrelit() ) );
        }
	}

	technique11 Wireframe
	{
        pass p0
		{
			SetRasterizerState(g_rasterizerState);
            SetVertexShader( CompileShader( vs_5_0, VShaderPrelit() ) );
			SetGeometryShader( CompileShader( gs_5_0, GShaderPrelit_Wireframe() ) );
            SetPixelShader( CompileShader( ps_5_0, PShaderPrelit() ) );
        }
	}
}
#undef PRELIT
