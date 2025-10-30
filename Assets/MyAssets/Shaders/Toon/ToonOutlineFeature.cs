using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;
[Serializable]
public class ToonOutlineFeature : ScriptableRendererFeature {
  [Serializable]
  public class ToonOutlinePass : ScriptableRenderPass {
    [Serializable]
    class PassData {
      public RendererListHandle rendererListHandle;
    }
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameContext) {
      string passName = "ToonOutlinePass";
      var renderingData = frameContext.Get<UniversalRenderingData>();
      var resourceData = frameContext.Get<UniversalResourceData>();
      var desc = new RendererListDesc(
        // use with override shader or material to work for all objects
        // new[] { new ShaderTagId(passName), new ShaderTagId("UniversalForward") },
        new ShaderTagId(passName),
        renderingData.cullResults,
        frameContext.Get<UniversalCameraData>().camera
      ) {
        sortingCriteria = SortingCriteria.CommonOpaque,
        renderQueueRange = RenderQueueRange.all,
        layerMask = ~0
      };
      var rendererListHandle = renderGraph.CreateRendererList(desc);
      var textureDesc = resourceData.activeColorTexture.GetDescriptor(renderGraph);
      var texture = renderGraph.CreateTexture(textureDesc);
      renderGraph.AddBlitPass(resourceData.activeColorTexture, texture, new Vector2(1.0f, 1.0f), new Vector2(0.0f, 0.0f));
      using (var builder = renderGraph.AddRasterRenderPass(passName,
          out PassData passData)) {
        passData.rendererListHandle = rendererListHandle;
        builder.SetRenderAttachmentDepth(resourceData.activeDepthTexture);
        builder.UseRendererList(rendererListHandle);
        builder.SetRenderAttachment(texture, 0);
        builder.SetRenderFunc(static (PassData data, RasterGraphContext context) => {
          // context.cmd.ClearRenderTarget(true, true, Color.white);
          context.cmd.DrawRendererList(data.rendererListHandle);
        });
      }
      renderGraph.AddBlitPass(texture, resourceData.activeColorTexture, new Vector2(1.0f, 1.0f), new Vector2(0.0f, 0.0f));
    }
  }
  public ToonOutlinePass outlinePass;
  public override void Create() {
    outlinePass = new ToonOutlinePass() {
      renderPassEvent = RenderPassEvent.AfterRenderingTransparents
    };
  }
  public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
    renderer.EnqueuePass(outlinePass);
  }
}
