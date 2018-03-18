import std.stdio;
import polyplex.core;
import polyplex.utils.logging;
import polyplex.math;
import std.conv;
import std.random;
import sev.event;

void main(string[] args)
{
	import polyplex;
	BasicGameLauncher.InitSDL();
	LogLevel |= LogType.Debug;
	BasicGameLauncher.LaunchGame(new MyGame(), args);
}

struct Particle {
	int sprite_id;
	Vector2 position;
	Vector2 momentum;
	float rotation;
	Color color;
	Rectangle draw_rect;
}

class MyGame : Game {
	Texture2D[] particle_imgs;
	Texture2D pp_logo;
	Camera2D cam;

	Particle[] particles;

	this() {
		super("Particle example", new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined));
	}

	public override void Init() {
		this.Content.ContentRoot = "Content/";
		
		//this.particle = this.Content.LoadTexture("particles.png");
		particle_imgs.length = 17;
		for (int i = 0; i < 17; i++) {
			particle_imgs[i] = this.Content.LoadTexture("sprseq" ~ (i+1).text);
		}
		this.pp_logo = this.Content.LoadTexture("pplogo");
		this.cam = new Camera2D(Vector2(0, 0));
		this.cam.Origin = Vector2((Window.Width/2)-16, (Window.Height/2)-16);

		this.particles.length++;
		this.particles[0] = Particle(0, Vector2(0, 0), Vector2(1, -5), 0f, new Color(uniform(0, 255, r), uniform(0, 255, r), uniform(0, 255, r)), new Rectangle(0, 0, 16, 16));



		this.OnWindowSizeChanged += &OnWindowResize;
		r = Random(unpredictableSeed);

		for (int i = 0; i < 10000; i++) {
			this.particles.length++;
			this.particles[this.particles.length-1] = Particle(
				0, //uniform(0, cast(int)particle_imgs.length, r),
				Vector2(0, 0),
				Vector2(uniform(-10f, 10f, r), uniform(-10f, 10f, r)),
				0f,
				new Color(uniform(0, 255, r), uniform(0, 255, r), uniform(0, 255, r)),
				new Rectangle(0, 0, 16, 16)
			);
		}
		Window.AllowResizing = true;
		Window.VSync = true;
	}

	public override void LoadContent() {
	}

	private Random r;
	private float ft;

	private void OnWindowResize(void* sender, EventArgs e) {
		this.cam.Origin = Vector2((Window.Width/2)-16, (Window.Height/2)-16);
	}

	public override void Update(GameTimes game_time) {
		if (Input.IsKeyDown(KeyCode.KeyUp)) {
			this.particles.length++;
			this.particles[this.particles.length-1] = Particle(
				0, //uniform(0, cast(int)particle_imgs.length, r),
				Vector2(0, 0),
				Vector2(uniform(-10f, 10f, r), uniform(-10f, 10f, r)),
				0f,
				new Color(uniform(0, 255, r), uniform(0, 255, r), uniform(0, 255, r)),
				new Rectangle(0, 0, 16, 16)
			);
		} else if (Input.IsKeyDown(KeyCode.KeyDown)) {
			if (this.particles.length > 0) {
				destroy(this.particles[this.particles.length-1]);
				this.particles.length--;
			}
		}

		for (int i = 0; i < particles.length; i++) {
			particles[i].position += particles[i].momentum;
			particles[i].momentum.Y += 0.1f;
			if (particles[i].momentum.Y > 10f) particles[i].momentum.Y = 10f;

			if (particles[i].momentum.X > 0f) particles[i].rotation += 0.01f;
			else particles[i].rotation -= 0.01f;

			if (particles[i].position.Y > this.Window.Height) {
				particles[i].position = Vector2(0, 0);
				particles[i].momentum = Vector2(uniform(-10f, 10f, r), uniform(-10f, 10f, r));
				particles[i].rotation = 0f;
			}
		}
		if (this.Frametime != ft) {
			Window.Title = "Particle Stress Test | " ~ this.particles.length.text ~ " | " ~ this.Frametime.text ~ "ms";
		}
		ft = this.Frametime;
	}

	private Color ppcol = new Color(255, 255, 255, 128);

	public override void Draw(GameTimes game_time) {
		Drawing.ClearColor(Color.Black);
		this.sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, this.cam);
			foreach(Particle p; particles) {
				this.sprite_batch.Draw(this.particle_imgs[p.sprite_id], new Rectangle(cast(int)p.position.X, cast(int)p.position.Y, 32, 32), p.draw_rect, p.rotation, Vector2(16, 16), p.color);
			}
		this.sprite_batch.End();
		this.sprite_batch.Begin();
			this.sprite_batch.Draw(this.pp_logo, new Rectangle(0, 0, this.pp_logo.Width/5, this.pp_logo.Height/5), new Rectangle(0, 0, this.pp_logo.Width, this.pp_logo.Height), ppcol);
		this.sprite_batch.End();
	}

}
