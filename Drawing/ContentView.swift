//
//  ContentView.swift
//  Drawing
//
//  Created by Luis Calvillo on 5/24/24.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    
    @State private var canvas = PKCanvasView()
    @State private var isDrawing = true
    @State private var color: Color = .red
    @State private var pencilType: PKInkingTool.InkType = .pencil
    @State private var colorPicker = false
    @Environment(\.undoManager) private var undoManager
    
    @State private var lineWidth:CGFloat = 5
    @State private var opacity:Double = 1.0
    
    @State private var showingAlert = false
    
    
    var body: some View {
        NavigationStack {
            DrawingView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color, lineWidth: $lineWidth, opacity: $opacity)
                .toolbar {
                    // Bottom Toolbar
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack(alignment: .bottom, spacing: 16) { // Drawing Tools
                            // Pencil
                            Button {
                                isDrawing = true
                                pencilType = .pencil
                                pencilType.defaultWidth
                            } label: {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Pen
                            Button {
                                isDrawing = true
                                pencilType = .pen
                            } label: {
                                Image(systemName: "applepencil.tip")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Monoline
                            Button {
                                isDrawing = true
                                pencilType = .monoline
                            } label: {
                                Image(systemName: "line.diagonal")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Fountain: Variable scribbling
                            Button {
                                isDrawing = true
                                pencilType = .fountainPen
                            } label: {
                                Image(systemName: "paintbrush.pointed")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Marker
                            Button {
                                isDrawing = true
                                pencilType = .marker
                            } label: {
                                Image(systemName: "pencil.tip")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Crayon
                            Button {
                                isDrawing = true
                                pencilType = .crayon
                            } label: {
                                Image(systemName: "medical.thermometer")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                            // Water Color
                            Button {
                                isDrawing = true
                                pencilType = .watercolor
                            } label: {
                                Image(systemName: "paintbrush.pointed")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        } // Drawing Tools
                    }
                }
            
            // Top Toolbar
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        // Modify Tools
                        HStack(spacing: 32) {
                            
                            Button {
                                // Clear the canvas. Reset the drawing
                                showingAlert = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .alert("Are you sure you want to erase your canvas?", isPresented: $showingAlert) {
                                Button("Yes", role: .destructive) {
                                    canvas.drawing = PKDrawing()
                                }
                            }
                            
                            Button {
                                // Undo drawing
                                undoManager?.undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            
                            Button {
                                // Redo drawing
                                undoManager?.redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward")
                            }
                            
                            Button {
                                // Erase tool
                                isDrawing = false
                            } label: {
                                Image(systemName: "eraser.line.dashed")
                            }
                            
                            ColorPicker("", selection: $color)
                        } // Modify tools
                        .padding(12)
                        .buttonStyle(.plain)
                    }
                }
        }
    }
}


// MARK: - Canvas

struct DrawingView: UIViewRepresentable {
    // Capture drawings for saving in the photos library
    @Binding var canvas: PKCanvasView
    @Binding var isDrawing: Bool
    // Ability to switch a pencil
    @Binding var pencilType: PKInkingTool.InkType
    // Ability to change a pencil color
    @Binding var color: Color
    
    // new chatgpt
    @Binding var lineWidth: CGFloat
    @Binding var opacity: Double
    
    // ChatGPT answer for ink
    private func ink() -> PKInkingTool {
        let adjustedColor = color.opacity(opacity)
        var ink = PKInkingTool(pencilType, color: UIColor(adjustedColor))
        ink.width = lineWidth
        return ink
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        // Allow finger and pencil drawing
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDrawing ? ink() : eraser
        canvas.isRulerActive = false
        canvas.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        canvas.alwaysBounceVertical = true
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool whenever the main view updates
        uiView.tool = isDrawing ? ink() : eraser
    }
}

#Preview {
    ContentView()
}

