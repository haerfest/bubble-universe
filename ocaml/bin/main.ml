(* Bubble Universe
 * https://www.stardot.org.uk/forums/viewtopic.php?t=25833
 *
 * To run (macOS):
 * $ opam install ocamlsdl2
 * $ dune build
 * $ dune exec bubble
 *)

let (width, height, bpp) = (1280, 800, 3)
and (n, m) = (200, 200)
and (rx, ry) = (Float.pi *. 2.0 /. 235.0, 1.0)

let (sx, sy) = (float (width - 20) /. 4.0, float (height - 20) /. 4.0)
and (tx, ty) = (width / 2, height / 2)

let sc = Float.min sx sy

let plot pixels (x, y) (r, g, b) =
        let offset = (y * width + x) * bpp in
        Bytes.set pixels (offset + 0) (Char.chr b) ;
        Bytes.set pixels (offset + 1) (Char.chr g) ;
        Bytes.set pixels (offset + 2) (Char.chr r)

let plot4 pixels (x, y) rgb =
        plot pixels (x + 0, y + 0) rgb ;
        plot pixels (x + 1, y + 0) rgb ;
        plot pixels (x + 0, y + 1) rgb ;
        plot pixels (x + 1, y + 1) rgb

let bubble t dt =
        let pixels = Bytes.make (width * height * bpp) (Char.chr 0)
        and x = ref 0.0
        and y = ref 0.0 in
        for i = 0 to (n - 1) do
                x := 0.0 ;
                y := 0.0 ;
                for j = 0 to (m - 1) do
                        let a = !x +. (float i) *. rx +. t
                        and b = !y +. (float i) *. ry +. t in
                        x := Float.sin a +. Float.sin b ;
                        y := Float.cos a +. Float.cos b ;
                        let r = 255 * i / n
                        and g = 255 * j / m
                        and b = 255 * (n - i + m - j) / (n + m) in
                        plot4 pixels (tx + int_of_float (sc *. !x), ty + int_of_float (sc *. !y)) (r, g, b)
                done
        done ;
        (pixels, t +. dt /. 22.0)  (* About π / 4096 *)

let blit renderer surface pixels =
        Sdl.Surface.blit_pixels_unsafe surface (Bytes.to_string pixels) ;
        let texture = Sdl.Texture.create_from_surface renderer surface in
        Sdl.Render.copy renderer ~texture:texture () ;
        Sdl.Render.render_present renderer ;
        Sdl.Texture.destroy texture

let rec loop renderer surface ticks t =
        match Sdl.Event.poll_event () with
        | Some (Quit _) -> ()
        | Some (KeyDown {keycode = Sdlkeycode.Escape; _}) -> Sdlquit.quit ()
        | None ->
                let ticks' = Sdl.Timer.get_ticks () in
                let dt = float (ticks' - ticks) /. 1000.0 in
                let (pixels, t') = bubble t dt in
                blit renderer surface pixels ;
                loop renderer surface ticks' t'
        | _ -> loop renderer surface ticks t
 
let () =
        Sdl.init [`VIDEO] ;
        let window = Sdl.Window.create ~title:"Bubble Universe" ~pos:(`centered, `centered) ~dims:(width, height) ~flags:[Shown; FullScreen_Desktop] in
        let renderer = Sdl.Render.create_renderer ~win:window ~index:(-1) ~flags:[Accelerated; PresentVSync]
        and surface = Sdl.Surface.create_rgb ~width:width ~height:height ~depth:(bpp * 8) in
        loop renderer surface 0 0.0
