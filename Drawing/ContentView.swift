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
    @State private var saveImageAlert = false
    
    private var screenBoundsWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            DrawingView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color, lineWidth: $lineWidth, opacity: $opacity)
                .toolbar {
                    // Bottom Toolbar
                    ToolbarItemGroup(placement: .bottomBar) {
                        ZStack {
                            VStack {
                                HStack(alignment: .center) { // Drawing Tools
                                    // Pencil
                                    Button {
                                        isDrawing = true
                                        pencilType = .pencil
                                    } label: {
                                        Image("pencil")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .pencil ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Pen
                                    Button {
                                        isDrawing = true
                                        pencilType = .pen
                                    } label: {
                                        Image("pen")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .pen ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Monoline
                                    Button {
                                        isDrawing = true
                                        pencilType = .monoline
                                    } label: {
                                        Image("monoline")
                                            .resizable()
                                            .frame(width: 25, height: 70)
                                    }
                                    .padding(pencilType == .monoline ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Fountain: Variable scribbling
                                    Button {
                                        isDrawing = true
                                        pencilType = .fountainPen
                                    } label: {
                                        Image("fountain-pen")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .fountainPen ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Marker
                                    Button {
                                        isDrawing = true
                                        pencilType = .marker
                                    } label: {
                                        Image("marker")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .marker ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Crayon
                                    Button {
                                        isDrawing = true
                                        pencilType = .crayon
                                    } label: {
                                        Image("crayon")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .crayon ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    // Water Color
                                    Button {
                                        isDrawing = true
                                        pencilType = .watercolor
                                    } label: {
                                        Image("paintbrush")
                                            .resizable()
                                            .frame(width: 25, height: 75)
                                    }
                                    .padding(pencilType == .watercolor ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) : EdgeInsets(top: 0, leading: 0, bottom: -20, trailing: 0))
                                    
                                    ColorPicker("", selection: $color)
                                        .frame(width: 25, height: 75)
                                } // Drawing Tools
                                
                                .frame(width: screenBoundsWidth, height: 100)
                                .background(Color(.white.withAlphaComponent(0.9)))
                                .background(Color.gray)
                            }
                            
                            // Bottom tools cover
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color(UIColor.lightGray))
                                    .frame(height: 20)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .background(Color(UIColor.lightGray))
            
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
                            
                            Button {
                                saveDrawing()
                            } label: {
                                Image(systemName: "arrow.down.square")
                            }
                            .alert("Saved drawing to your photos album!", isPresented: $saveImageAlert) {
                                Button("Ok") {}
                            }
                        } // Modify tools
                        .padding(12)
                        .buttonStyle(.plain)
                    }
                }
        }
    }
    
    func saveDrawing() {
        // Get the drawing image from the canvas
        let drawingImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1.0)
        
        // Save drawings to the Photos Album
        UIImageWriteToSavedPhotosAlbum(drawingImage, nil, nil, nil)
                
        saveImageAlert = true
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
