shader_type canvas_item;

uniform sampler2D originalTexture;
uniform int winsize; // For example, 5 for a 5x5 window

vec3 calculateMean(vec2 center, int halfWinSize, bool horizontal, bool vertical) {
	vec3 sum = vec3(0.0);
	float count = 0.0;
	for (int y = -halfWinSize; y <= halfWinSize; ++y) {
		for (int x = -halfWinSize; x <= halfWinSize; ++x) {
			if(horizontal ? (x > 0) : (x <= 0))
				if(vertical ? (y > 0) : (y <= 0)) {
					sum += texture(originalTexture, center + vec2(float(x), float(y)) / vec2(textureSize(originalTexture, 0))).rgb;
					count += 1.0;
				}
		}
	}
	return sum / count;
}

vec3 calculateVariance(vec2 center, vec3 mean, int halfWinSize, bool horizontal, bool vertical) {
	vec3 sum = vec3(0.0);
	float count = 0.0;
	for (int y = -halfWinSize; y <= halfWinSize; ++y) {
		for (int x = -halfWinSize; x <= halfWinSize; ++x) {
			if(horizontal ? (x > 0) : (x <= 0))
				if(vertical ? (y > 0) : (y <= 0)) {
					vec3 diff = texture(originalTexture, center + vec2(float(x), float(y)) / vec2(textureSize(originalTexture, 0))).rgb - mean;
					sum += diff * diff;
					count += 1.0;
				}
		}
	}
	return sum / count;
}

void fragment() {
	vec2 center = UV;
	int halfWinSize = (winsize - 1) / 2;

	float minVariance = 1e5;
	vec3 resultMean = vec3(0.0);

	for(int vertical = 0; vertical < 2; ++vertical) {
		for(int horizontal = 0; horizontal < 2; ++horizontal) {
			vec3 mean = calculateMean(center, halfWinSize, horizontal == 1, vertical == 1);
			vec3 variance = calculateVariance(center, mean, halfWinSize, horizontal == 1, vertical == 1);
			float totalVariance = variance.r + variance.g + variance.b;

			if(totalVariance < minVariance) {
				minVariance = totalVariance;
				resultMean = mean;
			}
		}
	}
	
	COLOR = vec4(resultMean, 1.);
}
